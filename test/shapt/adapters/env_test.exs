defmodule Shapt.Adapters.EnvTest do
  use ExUnit.Case, async: true
  alias Shapt.Adapters.Env

  describe "load/2 from :file" do
    test "wihtout file confing" do
      assert %{} = Env.load([from: :file], a: %{})
    end

    test "load from file only existing keys" do
      assert %{a: true} == Env.load([from: :file, file: "test/support/testenv"], a: %{})
    end

    test "load unformatted key from file" do
      assert %{a: true, b: false} ==
               Env.load([from: :file, file: "test/support/testenv"], a: %{}, b: %{})
    end

    test "default unexisting key to false" do
      assert %{a: false} == Env.load([from: :file, file: "test/support/testenv"], a: %{key: "C"})
    end
  end

  describe "load/2 from :env" do
    test "with envvar set" do
      System.put_env("A", "true")
      assert %{a: true} == Env.load([], a: %{})
      System.put_env("A", "")
    end

    test "without envvar set" do
      assert %{a: false} == Env.load([], a: %{})
    end
  end

  describe "create_template/2" do
    test "generate template using key value" do
      assert "B=false" == Env.create_template([], a: %{key: "B"})
    end

    test "generate template for simple toggle name" do
      assert "A=false" == Env.create_template([], a: %{})
    end

    test "generate template for complex toggle name" do
      assert "A_LONG_KEY=false" == Env.create_template([], a_long_key?: %{})
    end
  end

  describe "validate_configuration/1" do
    test "from: :file with valid file" do
      assert :ok == Env.validate_configuration(from: :file, file: "test/support/testenv")
    end

    test "from: :file with invalid file" do
      assert "not a file" == Env.validate_configuration(from: :file, file: "some/file/env")
    end

    test "from: :file with no file opts" do
      assert "not a file" == Env.validate_configuration(from: :file)
    end

    test "from: :env" do
      assert :ok == Env.validate_configuration(from: :env)
    end

    test "empty opts" do
      assert :ok == Env.validate_configuration([])
    end
  end
end
