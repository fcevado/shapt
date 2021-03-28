defmodule Shapt.HelpersTest do
  use ExUnit.Case, async: true
  alias Shapt.Helpers

  describe "do_expired/2" do
    test "is expired" do
      assert Helpers.do_expired(:key, key: %{deadline: Date.utc_today()})
    end

    test "isn't expired" do
      deadline =
        Date.utc_today()
        |> Date.add(2)

      refute Helpers.do_expired(:key, key: %{deadline: deadline})
    end

    test "isn't expired without deadline" do
      refute Helpers.do_expired(:key, key: %{})
    end
  end

  describe "do_all_expired/1" do
    test "returns list of expired keys" do
      valid =
        Date.utc_today()
        |> Date.add(2)

      expired = Date.utc_today()

      assert [:b, :c] ==
               Helpers.do_all_expired(
                 a: %{deadline: valid},
                 b: %{deadline: expired},
                 c: %{deadline: expired},
                 d: %{deadline: valid}
               )
    end
  end

  describe "do_template/3" do
    test "apply template to adapter" do
      defmodule A do
        def create_template(_, _), do: "it's a template"
      end

      assert "it's a template" == Helpers.do_template(A, [], [])
    end
  end

  describe "apply_toggle/2 true" do
    test "with {function, args}" do
      fun = fn a -> 1 + a end
      assert 2 == Helpers.apply_toggle(true, on: {fun, [1]})
    end

    test "with {module, function, args}" do
      defmodule A do
        def b(c), do: c + 1
      end

      assert 2 == Helpers.apply_toggle(true, on: {A, :b, [1]})
    end

    test "with term" do
      assert 2 == Helpers.apply_toggle(true, on: 2)
    end
  end

  describe "apply_toggle/2 false" do
    test "with {function, args}" do
      fun = fn a -> 1 + a end
      assert 2 == Helpers.apply_toggle(false, off: {fun, [1]})
    end

    test "with {module, function, args}" do
      defmodule A do
        def b(c), do: c + 1
      end

      assert 2 == Helpers.apply_toggle(false, off: {A, :b, [1]})
    end

    test "with term" do
      assert 2 == Helpers.apply_toggle(false, off: 2)
    end
  end
end
