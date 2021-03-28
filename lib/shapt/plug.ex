if Code.ensure_loaded?(Plug) do
  defmodule Shapt.Plug do
    @moduledoc """
    This plug provides two endpoints:
    - GET that will that will return the current value of your toggles on runtime.
    - POST that will reload the current value of your toggles on runtime.
    ```
    plug Shapt.Plug,
      path: "/toggles",
      modules: [TestModule]
    ```
    """
    use Plug.Router

    plug(:match)
    plug(:dispatch, builder_opts())

    get _ do
      with true <- conn.request_path == opts[:path],
           true <- Enum.all?(opts[:modules], &Code.ensure_loaded?/1),
           true <- Enum.all?(opts[:modules], &(&1 |> Process.whereis() |> is_pid())) do
        opts[:modules]
        |> Enum.map(&{&1, &1.all_values()})
        |> prepare_response(conn, 200, opts[:formatter])
      else
        _ ->
          conn
      end
    end

    post _ do
      with true <- conn.request_path == opts[:path],
           true <- Enum.all?(opts[:modules], &Code.ensure_loaded?/1) do
        opts[:modules]
        |> Enum.map(& &1.reload())

        opts[:modules]
        |> Enum.map(&{&1, &1.all_values()})
        |> prepare_response(conn, 201, opts[:formatter])
      else
        _ ->
          conn
      end
    end

    match _ do
      conn
    end

    defp halt_with_response(conn, type, status, body) do
      conn
      |> halt
      |> put_resp_content_type(type)
      |> send_resp(status, body)
    end

    defp prepare_response(modules, conn, status, Jason) do
      body = format_jason(modules)
      halt_with_response(conn, "application/json", status, body)
    end

    defp prepare_response(modules, conn, status, Poison) do
      body = format_poison(modules)
      halt_with_response(conn, "application/json", status, body)
    end

    defp prepare_response(modules, conn, status, _) do
      body = format_text(modules)
      halt_with_response(conn, "text/plain", status, body)
    end

    defp format_text(modules) do
      modules
      |> Enum.map(&format_string/1)
      |> Enum.join("\n")
    end

    defp format_string({mod, keys}) do
      "#{inspect(mod)}: #{inspect(keys, pretty: true, width: 20)}"
    end

    defp format_jason(modules) do
      modules
      |> Enum.map(fn {k, v} -> {inspect(k), v} end)
      |> Enum.into(%{})
      |> Jason.encode!(escape: :html_safe, pretty: true)
    end

    defp format_poison(modules) do
      modules
      |> Enum.map(fn {k, v} -> {inspect(k), v} end)
      |> Enum.into(%{})
      |> Poison.encode!()
    end
  end
end
