defmodule Shapt.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  describe "GET" do
    test "with no formatter" do
      {pid, opts} = prepare(path: "/test", modules: [TestShapt])

      conn =
        :get
        |> conn("/test")
        |> Shapt.Plug.call(opts)

      assert 200 == conn.status
      assert :sent == conn.state
      assert "TestShapt: %{\n  feature_x: false,\n  feature_y: false\n}" == conn.resp_body

      GenServer.stop(pid, :normal)
    end

    test "with Jason" do
      {pid, opts} = prepare(path: "/test", modules: [TestShapt], formatter: Jason)

      conn =
        :get
        |> conn("/test")
        |> Shapt.Plug.call(opts)

      assert 200 == conn.status
      assert :sent == conn.state

      assert %{"TestShapt" => %{"feature_x" => false, "feature_y" => false}} ==
               parse_response(conn.resp_body)

      GenServer.stop(pid, :normal)
    end

    test "with Poison" do
      {pid, opts} = prepare(path: "/test", modules: [TestShapt], formatter: Poison)

      conn =
        :get
        |> conn("/test")
        |> Shapt.Plug.call(opts)

      assert 200 == conn.status
      assert :sent == conn.state

      assert %{"TestShapt" => %{"feature_x" => false, "feature_y" => false}} ==
               parse_response(conn.resp_body)

      GenServer.stop(pid, :normal)
    end
  end

  describe "POST" do
    test "with no formatter" do
      {pid, opts} = prepare(path: "/test", modules: [TestShapt])

      System.put_env("A", "true")
      System.put_env("B", "true")

      conn =
        :post
        |> conn("/test")
        |> Shapt.Plug.call(opts)

      assert 201 == conn.status
      assert :sent == conn.state
      assert "TestShapt: %{\n  feature_x: true,\n  feature_y: true\n}" == conn.resp_body

      System.put_env("A", "")
      System.put_env("B", "")
      GenServer.stop(pid, :normal)
    end

    test "with Jason" do
      {pid, opts} = prepare(path: "/test", modules: [TestShapt], formatter: Jason)

      System.put_env("A", "true")
      System.put_env("B", "true")

      conn =
        :post
        |> conn("/test")
        |> Shapt.Plug.call(opts)

      assert 201 == conn.status
      assert :sent == conn.state

      assert %{"TestShapt" => %{"feature_x" => true, "feature_y" => true}} ==
               parse_response(conn.resp_body)

      System.put_env("A", "")
      System.put_env("B", "")
      GenServer.stop(pid, :normal)
    end

    test "with Poison" do
      {pid, opts} = prepare(path: "/test", modules: [TestShapt], formatter: Poison)

      System.put_env("A", "true")
      System.put_env("B", "true")

      conn =
        :post
        |> conn("/test")
        |> Shapt.Plug.call(opts)

      assert 201 == conn.status
      assert :sent == conn.state

      assert %{"TestShapt" => %{"feature_x" => true, "feature_y" => true}} ==
               parse_response(conn.resp_body)

      System.put_env("A", "")
      System.put_env("B", "")
      GenServer.stop(pid, :normal)
    end
  end

  defp prepare(opts) do
    {:ok, pid} = TestShapt.start_link([])
    opts = Shapt.Plug.init(opts)

    {pid, opts}
  end

  defp parse_response(body), do: Jason.decode!(body)
end
