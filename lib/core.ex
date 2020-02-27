defmodule Ivy.Core do
  @type id :: non_neg_integer
  @type temp_id :: String.t
  @type ident :: atom
  @type instant :: DateTime.t
  @type t_value :: non_neg_integer
  @type tx_id :: id
  @type time_point :: instant | tx_id | t_value
  @type name :: String.t | atom
  @type basis :: t_value
end
