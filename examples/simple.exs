use Ivy

result = run 1, [x, y, z] do
  unify(x, z)
  unify(3, z)
  unify(y, x)
end
# => [[3, 3, 3]]

result_with_fresh =
  run 1, [q] do
    fresh [x, z] do
      unify(x, z)
      unify(3, z)
      unify(q, x)
    end
  end
# => [3]
