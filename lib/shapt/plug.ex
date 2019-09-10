defmodule Shapt.Plug do
  @moduledoc """
  This plug provides two endpoints:
  - GET that will that will return the current value of your toggles on runtime.
  - POST that will reload the current value of your toggles on runtime.

  Those features work better when you're caching values on ets with the `ets_cache` option set as true.
  This can be configured with the options `path` and `modules`, like the example:
  ```
  plug Shapt.Plug,
    path: "/toggles",
    modules: [TestModule]
  ```
  """
  if Code.ensure_loaded?(Plug) do
    use Plug.Router

    plug(:match)
    plug(:dispatch, builder_opts())

    get _ do
      with true <- conn.request_path == opts[:path],
           true <- Enum.all?(opts[:modules], &Code.ensure_loaded?/1) do
        body =
          opts[:modules]
          |> Enum.map(&"#{inspect(&1)}: #{inspect(&1.all_values(), pretty: true, width: 10)}")
          |> Enum.join("\n")

        halt_with_response(conn, 200, body)
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

        modules =
          opts[:modules]
          |> Enum.map(&inspect/1)
          |> Enum.join(",")

        halt_with_response(conn, 201, "reloaded: #{modules}")
      else
        _ ->
          conn
      end
    end

    match _ do
      conn
    end

    defp halt_with_response(conn, status, body) do
      conn
      |> halt
      |> put_resp_content_type("text/plain")
      |> send_resp(status, body)
    end
  end
end
