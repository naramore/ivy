defprotocol Ivy.Unifyable do
  @fallback_to_any true

  def unify(u, v, s)
end

defimpl Ivy.Unifyable, for: List do
  alias Ivy.{LVar, Package}

  def unify([_ | ut] = u, v, s)
    when not is_list(ut) and is_list(v) and length(v) >= 0 do
      unify_improper_u(u, v, s)
  end
  def unify([_ | ut] = u, [_ | vt] = v, s)
    when not is_list(ut) and not is_list(vt) do
      unify_improper_v(u, v, s)
  end
  def unify(u, [_ | vt] = v, s)
    when length(u) >= 0 and not is_list(vt) do
      @protocol.unify(v, u, s)
  end
  def unify(u, v, s)
    when is_list(v) and length(u) == length(v) do
      unify_proper(u, v, s)
  end
  def unify(_, _, _), do: nil

  defp unify_improper_u([uh | ut], [vh | vt] = v, s)
    when not is_list(ut) and length(v) >= 0 do
      case Package.unify(s, uh, vh) do
        nil -> nil
        s -> unify_improper_u(ut, vt, s)
      end
  end
  defp unify_improper_u(u, v, s)
    when is_list(v) and length(v) >= 0 do
      Package.unify(s, u, v)
  end
  defp unify_improper_u(%LVar{} = u, nil, s) do
    case Package.unify(s, u, []) do
      nil -> Package.unify(s, u, nil)
      s -> s
    end
  end
  defp unify_improper_u(_, _, _), do: nil

  defp unify_improper_v(%LVar{} = u, v, s), do: Package.unify(s, u, v)
  defp unify_improper_v(u, %LVar{} = v, s), do: Package.unify(s, v, u)
  defp unify_improper_v([uh | ut], [vh | vt], s)
    when not is_list(ut) and not is_list(vt) do
      case Package.unify(s, uh, vh) do
        nil -> nil
        s -> unify_improper_v(ut, vt, s)
      end
  end
  defp unify_improper_v(u, v, s), do: Package.unify(s, u, v)

  defp unify_proper([uh | ut] = u, [vh | vt] = v, s)
    when length(u) >= 0 and length(v) >= 0 do
      case Package.unify(s, uh, vh) do
        nil -> nil
        s -> unify_proper(ut, vt, s)
      end
  end
  defp unify_proper(u, _, _)
    when is_list(u) and length(u) >= 0 do
      nil
  end
  defp unify_proper(_, v, _)
    when is_list(v) and length(v) >= 0 do
      nil
  end
  defp unify_proper(_, _, s), do: s
end

defimpl Ivy.Unifyable, for: Map do
  alias Ivy.Package

  @not_found :__not_found__

  def not_found(), do: @not_found

  def unify(u, v, s)
    when is_map(v) and map_size(u) == map_size(v) do
      unify_impl(Map.keys(u), u, v, s)
  end
  def unify(_, _, _), do: nil

  defp unify_impl([], _, _, s), do: s
  defp unify_impl([ukf | uks], u, v, s) do
    with vf when vf != @not_found <- Map.get(v, ukf, @not_found),
         s when not is_nil(s) <- Package.unify(s, Map.get(u, ukf), vf) do
      unify_impl(uks, u, v, s)
    else
      _ -> nil
    end
  end
end

defimpl Ivy.Unifyable, for: Any do
  def unify(nil, nil, s), do: s
  def unify(nil, _, _), do: nil
  def unify(u, u, s), do: s
  def unify(_, _, _), do: nil
end
