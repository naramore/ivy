defmodule Ivy.Core.Pull do
  alias Ivy.{Core, Core.Datom}

  # pattern            = [attr-spec+]
  # attr-spec          = attr-name | wildcard | map-spec | attr-with-opts | attr-expr
  # attr-name          = an edn keyword that names an attr
  # map-spec           = { ((attr-name | attr-with-opts | attr-expr) (pattern | recursion-limit))+ }
  # attr-with-opts     = [attr-name attr-options+]
  # attr-options       = :as any-value | :limit (positive-number | nil) | :default any-value
  # wildcard           = '*'
  # recursion-limit    = positive-number | '...'
  # attr-expr          = limit-expr | default-expr
  # limit-expr         = [("limit" | 'limit') attr-name (positive-number | nil)]
  # default-expr       = [("default" | 'default') attr-name any-value]

  @type t :: [attr_spec, ...]
  @type attr_spec :: attr_name | wildcard | map_spec | attr_with_opts | attr_expr
  @type attr_name :: Core.ident
  @type map_spec :: %{required(attr_name | attr_with_opts | attr_expr) => t | recursion_limit}
  @type attr_with_opts :: {attr_name, [attr_options, ...]}
  @type attr_options :: {:as, Datom.value} | {:limit, pos_integer | nil} | {:default, Datom.value}
  @type wildcard :: :*
  @type recursion_limit :: pos_integer | :...
  @type attr_expr :: limit_expr | default_expr
  @type limit_expr :: {:limit, attr_name, pos_integer | nil}
  @type default_expr :: {:default, attr_name, Datom.value}


end
