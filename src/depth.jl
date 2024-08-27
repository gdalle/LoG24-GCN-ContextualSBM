function accuracy_zeroth_layer(csbm::CSBM; rtol)
    (; sbm, features) = csbm
    (; sizes) = sbm
    densities0 = features
    mix0 = Mixture(densities0, sizes ./ sum(sizes))
    return accuracy_quadrature(mix0; rtol)
end

function accuracy_first_layer(csbm::CSBM; rtol, kwargs...)
    (; sbm) = csbm
    (; sizes) = sbm
    densities1 = first_layer_densities(csbm; kwargs...)
    mix1 = Mixture(densities1, sizes ./ sum(sizes))
    return accuracy_quadrature(mix1; rtol)
end

function accuracy_trajectories(
    rng::AbstractRNG, csbm::CSBM; method=:randomwalk, nb_layers, nb_trajectories, kwargs...
)
    if method == :randomwalk
        return random_walk_accuracy_trajectories(
            rng, csbm; nb_layers, nb_trajectories, kwargs...
        )
    elseif method == :logisticregression
        return logistic_regression_accuracy_trajectories(
            rng, csbm; nb_layers, nb_trajectories, kwargs...
        )
    end
end

function accuracy_by_depth(rng::AbstractRNG, csbm::CSBM; kwargs...)
    accuracies = accuracy_trajectories(rng, csbm; kwargs...)
    return MonteCarloValue.(Vector.(eachrow(accuracies)))
end

function optimal_depth(rng::AbstractRNG, csbm::CSBM; kwargs...)
    accuracies = accuracy_trajectories(rng, csbm; kwargs...)
    return MonteCarloValue(argmax.(eachcol(accuracies)) .- 1)
end
