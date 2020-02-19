using BenchmarkTools, JuliaDBMeta, CategoricalArrays, StatsBase, JuliaDB

abstract type PopObj end

mutable struct PopSample <: PopObj
    name::String
    population::String
    ploidy::Int8
    longitude::Union{Missing, Float32}
    latitude::Union{Missing, Float32}
end

struct PopData <: PopObj
    samples::Vector{PopSample}
    loci::T where T<:IndexedTable
end


##### gulfsharks stuff
function gulfsharks_lf_table()
  sharks = gulfsharks();
  sharks_df =  insertcols!(sharks.loci,1,:name => sharks.samples.name)
  sharks_df =  insertcols!(sharks.loci,2,:population => sharks.samples.population)
  sharks_df_long = DataFrames.stack(sharks_df, 3:2215)
  b = deepcopy(sharks_df_long)
  rename!(sharks_df_long, [:locus, :genotype, :name, :population])
  sharks_df_long.locus = string.(sharks_df_long.locus)
  sharks_table_noncat = sharks_df_long |> table
  #=Base.summarysize(sharks_df_long)
  12671248 =#
  categorical!(sharks_df_long, :locus)
  categorical!(sharks_df_long, :population)
  categorical!(sharks_df_long, :name)


  sharks_table = sharks_df_long |> table
  return sharks_df, b, sharks_df_long, sharks_table, sharks_table_noncat
end
a,b,c,d,e = gulfsharks_lf_table()
#a standard loci DF
#b long-format loci DF no CatArrays
#c long-format loci DF with CatArrays
#d long-format JDB table with CategoricalArrays
#e long-format JDB table without categorical

sharks = gulfsharks();

### missing by pop
@btime @groupby d :population {missing = sum(ismissing.(:genotype))}
@btime @groupby e :population {missing = sum(ismissing.(:genotype))}
@btime PopGen.missing(sharks, mode = "pop")
@btime by(c, :population, miss = :genotype => i -> sum(ismissing.(i)))

### missing by loc
@btime @groupby d :locus {missing = sum(ismissing.(:genotype))}
@btime @groupby e :locus {missing = sum(ismissing.(:genotype))}
@btime PopGen.missing(sharks, mode = "locus")
@btime @by(c, :locus, miss = sum(ismissing.(:genotype)))
@btime by(c, :locus, miss = :genotype => i -> sum(ismissing.(i)))



# het?
@btime by(c, :population, het = :genotype => i -> mean(length.(unique.(skipmissing(i) |> collect))))
# 156.256 ms (2787474 allocations: 236.78 MiB)
@btime by(c, :locus, het = :genotype => i -> mean(length.(unique.(skipmissing(i) |> collect))))
# 179.847 ms (3055436 allocations: 244.91 MiB)

@btime @groupby d (:locus) {hetero = mean(ishet.(:genotype) |> skipmissing)}
# 543.717 ms (2851555 allocations: 241.94 MiB)
@btime @groupby d (:locus, :population) {hetero = mean(length.(unique.(skipmissing(:genotype) |> collect)) .> 1)}
# 2.871 s (3184984 allocations: 306.68 MiB)
@btime @groupby e (:locus) {hetero = mean(length.(unique.(skipmissing(:genotype) |> collect)) .> 1)}
# 246.636 ms (2844834 allocations: 241.48 MiB)
@btime @groupby e (:population) {hetero = mean(length.(unique.(skipmissing(:genotype) |> collect)) .> 1)}
# 163.241 ms (2787463 allocations: 230.18 MiB)
@btime @groupby e (:locus, :population) {hetero = mean(length.(unique.(skipmissing(:genotype) |> collect)) .> 1)}
# 278.037 ms (3149464 allocations: 306.51 MiB)

Profile.@profile PopGen.het_observed(sharks)
# 1.318 s (1894933 allocations: 48.14 MiB)
@btime PopGen.het_population_obs(sharks)
# 71.318 ms (580830 allocations: 28.91 MiB)


# DataFrames
## CategoricalArrays
@btime by(b, :locus, het = :genotype => i -> mean(length.(unique.(skipmissing(i) |> collect))))
# 179.847 ms (3055436 allocations: 244.91 MiB)

## Regular String arrays
@btime by(c, :locus, het = :genotype => i -> mean(length.(unique.(skipmissing(i) |> collect))))
#  175.727 ms (2830513 allocations: 245.18 MiB)

#JuliaDB
## CategoricalArrays
@groupby d (:locus) {hetero = mean(length.(unique.(skipmissing(:genotype) |> collect)) .> 1)}
# 543.717 ms (2851555 allocations: 241.94 MiB)

## Regular String arrays
@btime @groupby $e (:locus) {hetero = mean(length.(unique.(skipmissing(:genotype) |> collect)) .> 1)}
# 246.636 ms (2844834 allocations: 241.48 MiB)

function grouptest()
  @groupby d (:locus) {hetero = mean(length.(unique.(skipmissing(:genotype) |> collect)) .> 1)}
end

function nomacro()
  JuliaDB.groupby(i -> mean(length.(unique.(skipmissing(i) |> collect)) .> 1), d, :locus, select=:genotype)
end


Profile.clear()
Profile.@profile grouptest()
Profile.print()

@btime grouptest()

function groupdf()
  @btime by(b, :locus, het = :genotype => i -> mean(length.(unique.(skipmissing(i) |> collect))))
  @btime  @by(b, :locus, het = mean(length.(unique.(skipmissing(:genotype) |> collect))))
end

Profile.clear()
Profile.@profile groupdf()
Profile.print()


  @groupby d (:locus) {hetero = mean(length.(unique.(skipmissing(:genotype) |> collect)) .> 1)}