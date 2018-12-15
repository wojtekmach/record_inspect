defmodule RecordInspect do
  import Inspect.Algebra

  persistent_term_available? = function_exported?(:persistent_term, :get, 0)

  if persistent_term_available? do
    @key {__MODULE__, :records}

    def def(record_name, fields) do
      :persistent_term.put(@key, Map.put(records(), record_name, fields))
    end

    def records() do
      :persistent_term.get(@key)
    rescue
      ArgumentError ->
        %{}
    end

    def inspect(tuple, opts) do
      record_name = elem(tuple, 0)

      with {:ok, fields} <- Map.fetch(records(), record_name),
           true <- length(fields) == tuple_size(tuple) - 1 do
        record_inspect(tuple, fields, opts)
      else
        _ ->
          default_inspect(tuple, opts)
      end
    end

    defp record_inspect(record, fields, opts) do
      [record_name | values] = Tuple.to_list(record)
      inner = Inspect.List.inspect(Enum.zip(fields, values), opts)

      concat(["##{to_string(record_name)}(", inner, ")"])
    end
  else
    def def(_record_name, _fields) do
      IO.warn("RecordInspect.def/2 requires OTP 21.2+")
    end

    def inspect(tuple, opts) do
      default_inspect(tuple, opts)
    end
  end

  # Copied from Elixir
  defp default_inspect(tuple, opts) do
    open = color("{", :tuple, opts)
    sep = color(",", :tuple, opts)
    close = color("}", :tuple, opts)
    container_opts = [separator: sep, break: :flex]
    container_doc(open, Tuple.to_list(tuple), close, opts, &to_doc/2, container_opts)
  end
end

defimpl Inspect, for: Tuple do
  def inspect(tuple, opts) do
    RecordInspect.inspect(tuple, opts)
  end
end
