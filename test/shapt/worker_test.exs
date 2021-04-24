defmodule Shapt.WorkerTest do
  use ExUnit.Case, async: true
  alias Shapt.Worker

  describe "init/2" do
    test "fails when provided adapter doesn't implement adapter behaviour" do
      assert {:error, {A, "not an adapter"}} == Worker.init(adapter: A)
    end

    test "fails when adapter config is invalid" do
      defmodule A do
        @behaviour Shapt.Adapter

        def create_template(_, _), do: ""
        def load(_, _), do: %{}
        def validate_configuration(_), do: "invalid config"
      end

      assert {:error, {A, "invalid config"}} == Worker.init(adapter: A)
    end

    test "continue when config is valid" do
      defmodule A do
        @behaviour Shapt.Adapter

        def create_template(_, _), do: ""
        def load(_, _), do: %{}
        def validate_configuration(_), do: :ok
      end

      assert {:ok, nil, {:continue, [adapter: A]}} == Worker.init(adapter: A)
    end
  end

  describe "handle_contine/2" do
    test "build correct state from config" do
      defmodule A do
        def load(_, _), do: %{}
      end

      assert {:noreply, %{table: _, adapter: A, adapter_conf: nil, toggles_conf: [], toggles: []}} =
               Worker.handle_continue([adapter: A, toggle_conf: []], nil)
    end

    test "load ets table with adapter load" do
      defmodule A do
        def load(_, _), do: %{a: true, b: false}
      end

      {:noreply, %{table: ets}} = Worker.handle_continue([adapter: A, toggle_conf: []], nil)

      assert %{a: true, b: false} == ets |> :ets.tab2list() |> Enum.into(%{})
    end
  end

  describe "handle_call/3 for :all_values" do
    test "build all values from ets table" do
      table = :ets.new(:shapt, [:set, :private])
      :ets.insert_new(table, {:a, true})
      :ets.insert_new(table, {:b, false})

      assert {:reply, %{a: true, b: false}, %{table: table}} ==
               Worker.handle_call(:all_values, :ok, %{table: table})
    end
  end

  describe "handle_call/3 for {:enabled, _}" do
    test "returns nil if provided toggle is not a toggle" do
      assert {:reply, nil, %{toggles: []}} ==
               Worker.handle_call({:enabled, :some_toggle}, :ok, %{toggles: []})
    end

    test "returns nil if toggle is not present in ets" do
      table = :ets.new(:shapt, [:set, :private])

      assert {:reply, nil, %{toggles: [:some_toggle], table: table}} ==
               Worker.handle_call({:enabled, :some_toggle}, :ok, %{
                 toggles: [:some_toggle],
                 table: table
               })
    end

    test "returns toggle value" do
      table = :ets.new(:shapt, [:set, :private])
      :ets.insert_new(table, {:some_toggle, true})

      assert {:reply, true, %{toggles: [:some_toggle], table: table}} ==
               Worker.handle_call({:enabled, :some_toggle}, :ok, %{
                 toggles: [:some_toggle],
                 table: table
               })
    end
  end

  describe "handle_call/3 for :reload" do
    test "reload ets table with adapter response" do
      defmodule A do
        def load(_, _), do: %{a: true, b: false}
      end

      table = :ets.new(:shapt, [:set, :private])
      :ets.insert_new(table, {:a, false})
      :ets.insert_new(table, {:b, true})
      state = %{table: table, adapter: A}

      assert {:reply, :ok, state} == Worker.handle_call(:reload, :ok, state)
      assert %{a: true, b: false} == table |> :ets.tab2list() |> Enum.into(%{})
    end
  end
end
