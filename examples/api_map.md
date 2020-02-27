behavior:
  @spec bind(t, goal) :: t
  @spec mplus(t, thunk) :: t
  @spec take(t) :: Enumerable.t
  @spec reify(t, package) :: package
  @spec occurs?(t, t, package) :: boolean
  @spec build(t, package) :: package
api:
  core:
    @type goal_constructor :: (... -> goal)
    @type goal :: (package -> [package])
    @type thunk :: (() -> goal)
    @type package :: term
    @type choice :: term
    @type lvar :: term
    @spec run(pos_integer | :infinity, [lvar], [goal]) :: [term]
    @spec fresh([lvar], [goal]) :: goal
    @spec conde([goal | [goal]]) :: goal
    @spec unify(term, term) :: goal
    @spec alt([goal]) :: goal
    @spec also([goal]) :: goal
    @spec succeed() :: goal
    @spec fail() :: goal
    @spec all([goal]) :: goal
    @spec nilo(term) :: goal
    @spec emptyo(term) :: goal
    @spec conso(term, term, [term] | lvar) :: goal
    @spec firsto([term] | lvar, term) :: goal
    @spec resto([term] | lvar, term) :: goal
    @spec everyg(goal, [term]) :: goal
  core.match:
    @spec fne(args, do: body) :: goal
    @spec defe(atom, args, do: body) :: Macro.t
    @spec matche([term], do: [{pattern, :->, goal | [goals]}]) :: goal
    @spec fna(args, do: body) :: goal
    @spec defa(atom, args, do: body) :: Macro.t
    @spec matcha([term], do: [{pattern, :->, goal | [goals]}]) :: goal
    @spec fnu(args, do: body) :: goal
    @spec defu(atom, args, do: body) :: Macro.t
    @spec matchu([term], do: [{pattern, :->, goal | [goals]}]) :: goal
  core.debug:
    @spec log(String.t, log_level, meta) :: goal
    @spec puts(String.t) :: goal
    @spec trace_package() :: goal
    @spec trace_lvars(String.t, [lvar]) :: goal
  core.non_relational:
    @spec project([lvar], [goal]) :: goal
    @spec pred(term, (term -> boolean)) :: goal
    @spec is(term, term, (term -> term)) :: goal
    @spec conda([goal | [goal]]) :: goal
    @spec condu([goal | [goal]]) :: goal
    @spec copy(term, term) :: goal
    @spec lvaro(lvar) :: goal
    @spec nonlvaro(lvar) :: goal
  clp:
    @spec addcg(goal) :: goal
    @spec updatecg(goal) :: goal
    @spec remcg(goal) :: goal
    @spec runcg(goal) :: goal
    @spec stopcg(goal) :: goal
    @spec run_constraint(goal) :: goal
    @spec fix_constraints() :: goal
    @spec run_constraints([goal]) :: goal
    ...
    @spec reifyg(term) :: goal
    @spec cgoal(goal) :: goal
  clp.tree:
    @type partial_map :: term
    @spec membero(term, [term] | lvar) :: goal
    @spec member1o(term, [term] | lvar) :: goal
    @spec appendo([term] | lvar, [term] | lvar, [term] | lvar) :: goal
    @spec permuteo([term] | lvar, [term] | lvar) :: goal
    @spec disunify(term, term) :: goal
    @spec distincto([term]) :: goal
    @spec rembero(term, [term], [term]) :: goal
    @spec featurec(map, partial_map) :: goal
    @spec fnc(args, do: body) :: goal
    @spec defc(atom, args, do: body) :: Macro.t
    @spec predc(term, (term -> boolean)) :: goal
    @spec nafc(goal, [term]) :: goal
    @spec conjo([term], [term], term) :: goal
    @spec fixc(x, f, runnable, reifier) :: goal
    @spec treec(x, fc, reifier) :: goal
    @spec seqc(v) :: goal
  clp.fd:
  tabled:
    @type answer_cache :: term
    @type suspended_stream :: term
    @spec master(term, cache) :: goal
    @spec tabled(args, [goal]) :: goal_constructor
  nominal:
  unifier:
  dcg:
  pldb:
  clp.set:
  clp.prob:
  search:
