%%%-------------------------------------------------------------------
%%% @author Roman Shestakov <>
%%% @copyright (C) 2011, Roman Shestakov
%%% @doc
%%%
%%% @end
%%% Created : 19 Mar 2011 by Roman Shestakov <>
%%%-------------------------------------------------------------------
-module(mdigraph_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").

suite() ->
    [{timetrap,{seconds,30}}].

init_per_suite(Config) ->
    mnesia:start(),
    Edges =  [{"A", "B"}, {"A", "C"}, {"B", "D"}, {"C", "D"}, {"D", "E"}, {"E", "F"}],
    Vertices = ["A", "B", "C", "D", "E", "F"],
    [{edges, Edges}, {vertices, Vertices} | Config].

end_per_suite(_Config) ->
    mnesia:stop(),
    ok.

init_per_testcase(_TestCase, Config) ->
    MG = mdigraph:new(),
    DG = digraph:new(),
    Vertices = ?config(vertices, Config),
    Edges = ?config(edges, Config),
    %% init digraph and mdigraph with same data
    %% add vertices
    [mdigraph:add_vertex(MG, V) || V <- Vertices],
    [digraph:add_vertex(DG, V) || V <- Vertices],
    %% add edges
    [mdigraph:add_edge(MG, V1, V2) || {V1, V2} <- Edges],
    [digraph:add_edge(DG, V1, V2) || {V1, V2} <- Edges],
    [{mg, MG}, {dg, DG} | Config].

end_per_testcase(_TestCase, Config) ->
    MG = ?config(mg, Config),
    DG = ?config(dg, Config),
    %% delete graphs
    mdigraph:delete(MG),
    digraph:delete(DG),
    ok.

all() -> 
    [
     add,
     source_sink,
     in_out_degree,
     in_out_neighbours,
     del_vertex,
     del_edge,
     path
    ].

add(Config) ->
    MG = ?config(mg, Config),
    DG = ?config(dg, Config),
    %% compare vertices could be in unspecified order
    MG_V = lists:sort(mdigraph:vertices(MG)),
    DG_V = lists:sort(digraph:vertices(DG)),
    ct:log("-> vertices, ~p, ~p ", [MG_V, DG_V]),
    MG_V = DG_V,
    %% compare edges
    MG_E = lists:sort(mdigraph:edges(MG)),
    DG_E = lists:sort(digraph:edges(DG)),
    ct:log("-> edges, ~p, ~p ", [MG_E, DG_E]),
    MG_E = DG_E,
    ok.

source_sink(Config) ->
    MG = ?config(mg, Config),
    DG = ?config(dg, Config),
    %% source
    MG_Source = mdigraph:source_vertices(MG),
    DG_Source = digraph:source_vertices(DG),
    ct:log("-> source_vertices, ~p, ~p ", [MG_Source, DG_Source]),
    MG_Source = DG_Source,
    %% sink
    MG_Sink = mdigraph:sink_vertices(MG),
    DG_Sink = digraph:sink_vertices(DG),
    ct:log("-> sink_vertices, ~p, ~p ", [MG_Sink, DG_Sink]),
    ok.

in_out_degree(Config) ->
    MG = ?config(mg, Config),
    DG = ?config(dg, Config),
    Vertices = ?config(vertices, Config),
    %% in degree
    MG_In_degree = [ {V, mdigraph:in_degree(MG, V)} || V <- Vertices ],
    DG_In_degree = [ {V, digraph:in_degree(DG, V)} || V <- Vertices ],
    ct:log("-> In_degree, ~p, ~p ", [MG_In_degree, DG_In_degree]),
    MG_In_degree = DG_In_degree,
    %% out degree
    MG_Out_degree = [ {V, mdigraph:out_degree(MG, V)} || V <- Vertices ],
    DG_Out_degree = [ {V, digraph:out_degree(DG, V)} || V <- Vertices ],
    ct:log("-> Out_degree, ~p, ~p ", [MG_Out_degree, DG_Out_degree]),
    MG_Out_degree = DG_Out_degree,
    ok.

in_out_neighbours(Config) ->
    MG = ?config(mg, Config),
    DG = ?config(dg, Config),
    Vertices = ?config(vertices, Config),
    %% in neighbours
    MG_In_N = [ {V, mdigraph:in_neighbours(MG, V)} || V <- Vertices ],
    DG_In_N = [ {V, digraph:in_neighbours(DG, V)} || V <- Vertices ],
    ct:log("-> In_neighbours, ~p,   ~p ", [MG_In_N, DG_In_N]),
    %ct:log("-> In_neighbours, ~p ", [ MG_In_N]),
    MG_In_N = DG_In_N,
    %% out neighbours
    MG_Out_neighbours = [ {V, mdigraph:out_neighbours(MG, V)} || V <- Vertices ],
    DG_Out_neighbours = [ {V, digraph:out_neighbours(DG, V)} || V <- Vertices ],
    ct:log("-> Out_neighbours, ~p, ~p ", [MG_Out_neighbours, DG_Out_neighbours]),
    MG_Out_neighbours = DG_Out_neighbours,
    %%ct:log("-> out_neighbours, ~p ", [ DG_Out_neighbours]),
    ok.

del_vertex(Config) ->
    MG = ?config(mg, Config),
    DG = ?config(dg, Config),
    Vertices = ?config(vertices, Config),    
    %% delete one node
    true = mdigraph:del_vertex(MG, "F"),
    true = digraph:del_vertex(DG, "F"),
    %% check that it is gone
    false = mdigraph:vertex(MG, "F"),
    false = digraph:vertex(DG, "F"),
    %% check length of remaining
    Exp_V = length(Vertices) - 1,
    Exp_V = mdigraph:no_vertices(MG),
    Exp_V = digraph:no_vertices(DG),
    %% try to delete no-existant
    true = mdigraph:del_vertex(MG, "F"),
    true = digraph:del_vertex(DG, "F"),
    Exp_V = mdigraph:no_vertices(MG),
    Exp_V = digraph:no_vertices(DG),
    %% delete two
    Exp_v2 = Exp_V - 2,
    true = mdigraph:del_vertices(MG, ["E", "D"]),
    true = digraph:del_vertices(DG,  ["E", "D"]),
    Exp_V2 = mdigraph:no_vertices(MG),
    Exp_V2 = digraph:no_vertices(DG),
    %% compare vertices could be in unspecified order
    MG_V = lists:sort(mdigraph:vertices(MG)),
    DG_V = lists:sort(digraph:vertices(DG)),
    ct:log("-> vertices, ~p, ~p ", [MG_V, DG_V]),
    MG_V = DG_V,
    %% compare edges
    MG_E = lists:sort(mdigraph:edges(MG)),
    DG_E = lists:sort(digraph:edges(DG)),
    ct:log("-> edges, ~p, ~p ", [MG_E, DG_E]),
    MG_E = DG_E,
    ok.

del_edge(Config) ->
    MG = ?config(mg, Config),
    DG = ?config(dg, Config),
    %% get edges
    MG_E = lists:sort(mdigraph:edges(MG)),
    DG_E = lists:sort(digraph:edges(DG)),
    %% delete one edge
    true = mdigraph:del_edge(MG, hd(MG_E)),
    true = digraph:del_edge(DG, hd(DG_E)),
    MG_E_2 = lists:sort(mdigraph:edges(MG)),
    DG_E_2 = lists:sort(digraph:edges(DG)),
    ct:log("-> edges, ~p, ~p ", [MG_E_2, DG_E_2]),
    MG_E_2 = DG_E_2,
    %% delete in the middle
    true = mdigraph:del_edge(MG, lists:nth(3, MG_E)),
    true = digraph:del_edge(DG, lists:nth(3, DG_E)),
    MG_E_3 = lists:sort(mdigraph:edges(MG)),
    DG_E_3 = lists:sort(digraph:edges(DG)),
    ct:log("-> edges, ~p, ~p ", [MG_E_3, DG_E_3]),
    MG_E_3 = DG_E_3,
    %% check vertices
    MG_V = lists:sort(mdigraph:vertices(MG)),
    DG_V = lists:sort(digraph:vertices(DG)),
    ct:log("-> vertices, ~p, ~p ", [MG_V, DG_V]),
    MG_V = DG_V,
    ok.

path(Config) ->
    MG = ?config(mg, Config),
    DG = ?config(dg, Config),
    %% source
    MG_Path = mdigraph:get_path(MG, "A", "E"),
    DG_Path = digraph:get_path(DG, "A", "E"),
    ct:log("-> path, ~p, ~p ", [MG_Path, DG_Path]),
    MG_Path = DG_Path,
    ok.
