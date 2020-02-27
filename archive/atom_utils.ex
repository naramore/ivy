defmodule AtomUtils do
  defmacro sigil_v(variable, [prefix | _]) do
    quote do
      :"#{unquote([prefix])}#{unquote(variable)}"
    end
  end
  defmacro sigil_v(variable, _modifiers) do
    quote do
      :"?#{unquote(variable)}"
    end
  end

  defmacro sigil_k(namespaced_atom, modifiers) do
    default_module = get_default_module(__CALLER__.module, modifiers)
    case build_namespaced_atom(namespaced_atom, default_module) do
      {:error, reason} -> raise reason
      {:ok, {prefix, atom}} ->
        quote do
          :"#{unquote(Enum.join(prefix, "."))}/#{unquote(atom)}"
        end
    end
  end

  defp get_default_module(nil, _modifiers), do: ["iex"]
  defp get_default_module(module, [?e]), do: Module.split(module)
  defp get_default_module(module, _modifiers) do
    tl(Module.split(module))
  end

  defp build_namespaced_atom({:<<>>, _, [atom_string]}, default_prefix) do
    case String.split(atom_string, "/") do
      [prefix, atom] -> {:ok, {String.split(prefix, "."), atom}}
      [atom] -> {:ok, {default_prefix, atom}}
      otherwise ->
        {:error, %ArgumentError{message: "atom string can contain only 1 '/', found: #{length(otherwise) - 1}"}}
    end
  end
end
