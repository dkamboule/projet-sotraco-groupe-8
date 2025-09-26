# types.jl - Définition des structures de données
module TypesSotraco
using DataFrames, Dates

export LigneBus, Arret, DonneesFrequentation, Recommendation

struct LigneBus
    id::Int
    nom_ligne::String
    origine::String
    destination::String
    distance_km::Float64
    duree_trajet_min::Int
    tarif_fcfa::Int
    frequence_min::Int
    statut::String
    capacite_bus::Int
end

struct Arret
    id::Int
    nom_arret::String
    quartier::String
    zone::String
    latitude::Float64
    longitude::Float64
    abribus::Bool
    eclairage::Bool
    lignes_desservies::String
end

struct DonneesFrequentation
    id::Int
    date::Date
    heure::Int
    ligne_id::Int
    arret_id::Int
    montees::Int
    descentes::Int
    occupation_bus::Int
    capacite_bus::Int
end

struct Recommendation
    ligne_id::Int
    nom_ligne::String
    frequence_actuelle::Int
    frequence_recommandee::Int
    taux_occupation_moyen::Float64
    gain_efficacite::Float64
    raison::String
end

end