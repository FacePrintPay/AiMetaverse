"""PaTHos OS Julia ML Layer - NLP2Code Integration for Constellation25/SovereignGPT"""
using JSON

struct PathosML
    config_path::String
    config::Dict
    models::Vector
    intents::Vector
    guardrails::Vector
end

function PathosML(config_path::String)
    config = JSON.parsefile(config_path)
    return PathosML(config_path, config, get(config, "models", []), get(config, "intents", []), get(config, "guardrails", []))
end

println("╔══════════════════════════════════════════════════════════╗")
println("║          PaTHos OS Julia ML Layer                        ║")
println("╚══════════════════════════════════════════════════════════╝")

ml = PathosML("nlp-training-data.json")
println("Loaded $(length(ml.models)) models")
println("Loaded $(length(ml.intents)) intents")
println("Loaded $(length(ml.guardrails)) guardrails")
