defmodule Checksum.ChecksumControllerTest do
  use ChecksumWeb.ConnCase, async: false
  alias Checksum.ChecksumAgent

  setup do
    on_exit(fn ->
      pid = Registry.whereis_name({ChecksumRegistry, "default-checksum"})
      unless :undefined == pid, do: ChecksumAgent.clear(pid)
    end)

    :ok
  end

  describe "add" do
    test "it can run multiple checksum sequences in isolation", %{conn: conn} do
      post(conn, "/v1/number", %{command: "A72"})
      post(conn, "/v1/number", %{command: "A94", id: "myid1"})
      post(conn, "/v1/number", %{command: "A11", id: "myid2"})
      post(conn, "/v1/number", %{command: "A12", id: "myid2"})

      default_sequence_pid = Registry.whereis_name({ChecksumRegistry, "default-checksum"})
      myid1_sequence_pid = Registry.whereis_name({ChecksumRegistry, "myid1"})
      myid2_sequence_pid = Registry.whereis_name({ChecksumRegistry, "myid2"})

      assert [72] = :queue.to_list(:sys.get_state(default_sequence_pid))
      assert [94] = :queue.to_list(:sys.get_state(myid1_sequence_pid))
      assert [11, 12] = :queue.to_list(:sys.get_state(myid2_sequence_pid))
    end

    test "on dirty input", %{conn: conn} do
      conn = post(conn, "/v1/number", %{command: "Ab32a321", id: "dirty"})
      state_pid = Registry.whereis_name({ChecksumRegistry, "dirty"})

      assert json_response(conn, 200) == %{"data" => "ok"}
      assert [32321] = :queue.to_list(:sys.get_state(state_pid))
    end

    test "on not a number", %{conn: conn} do
      conn = post(conn, "/v1/number", %{command: "Absss"})

      assert json_response(conn, 200) == %{"data" => "not_a_number"}
    end

    test "on empty", %{conn: conn} do
      conn = post(conn, "/v1/number", %{command: "A"})

      assert json_response(conn, 200) == %{"data" => "not_a_number"}
    end
  end

  describe "clear" do
    test "agent must be empty", %{conn: conn} do
      post(conn, "/v1/number", %{command: "A123"})
      state_pid = Registry.whereis_name({ChecksumRegistry, "default-checksum"})

      assert [123] = :queue.to_list(:sys.get_state(state_pid))
      conn = post(conn, "/v1/number", %{command: "C"})
      assert json_response(conn, 200) == %{"data" => "ok"}
      assert [] = :queue.to_list(:sys.get_state(state_pid))
    end
  end

  describe "checksum" do
    test "without id it produce checksum of default sequence", %{conn: conn} do
      DynamicSupervisor.start_child(ChecksumStateSupervisor, {ChecksumAgent, name: {:via, Registry, {ChecksumRegistry, "default-checksum"}}})
      default = {:via, Registry, {ChecksumRegistry, "default-checksum"}}
      ChecksumAgent.add(default, 10)
      ChecksumAgent.add(default, 10)

      conn = post(conn, "/v1/number", %{command: "CS"})

      assert json_response(conn, 200) == %{"data" => 0}
    end

    test "with id it produce checksum of the given sequence", %{conn: conn} do
      DynamicSupervisor.start_child(ChecksumStateSupervisor, {ChecksumAgent, name: {:via, Registry, {ChecksumRegistry, "custom"}}})
      custom = {:via, Registry, {ChecksumRegistry, "custom"}}
      ChecksumAgent.add(custom, 33)
      ChecksumAgent.add(custom, 33)

      conn = post(conn, "/v1/number", %{command: "CS", id: "custom"})
      assert json_response(conn, 200) == %{"data" => 8}
    end

    test "it should timeout at 15ms duration", %{conn: conn} do
      DynamicSupervisor.start_child(ChecksumStateSupervisor, {ChecksumAgent, name: {:via, Registry, {ChecksumRegistry, "timeout"}}})
      custom = {:via, Registry, {ChecksumRegistry, "timeout"}}
      for i <- 0..1_000_000, do: ChecksumAgent.add(custom, i)

      conn = post(conn, "/v1/number", %{command: "CS", id: "timeout"})
      assert json_response(conn, 200) == %{"data" => 8}
    end
  end
end
