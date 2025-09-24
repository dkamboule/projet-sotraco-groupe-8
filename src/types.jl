"""
Documentation du Module TypesSotraco
Vue d'ensemble
Le module TypesSotraco définit les structures de données principales pour un système de gestion de transport en commun (bus). 
Il utilise les packages DataFrames et Dates pour la manipulation de données et la gestion des dates.

Structures exportées
1. LigneBus
Représente une ligne de bus avec ses caractéristiques opérationnelles.

Champs :

id::Int : Identifiant unique de la ligne

nom_ligne::String : Nom de la ligne (ex: "Ligne 12")

origine::String : Point de départ de la ligne

destination::String : Point d'arrivée de la ligne

distance_km::Float64 : Distance totale du trajet en kilomètres

duree_trajet_min::Int : Durée estimée du trajet en minutes

tarif_fcfa::Int : Tarif du ticket en Franc CFA

frequence_min::Int : Fréquence de passage en minutes

statut::String : Statut de la ligne (ex: "Active", "Inactive")

2. Arret
Représente un arrêt de bus avec ses caractéristiques physiques et géographiques.

Champs :

id::Int : Identifiant unique de l'arrêt

nom_arret::String : Nom de l'arrêt

quartier::String : Quartier où se situe l'arrêt

zone::String : Zone géographique

latitude::Float64 : Coordonnée latitude

longitude::Float64 : Coordonnée longitude

abribus::Bool : Présence d'un abribus

eclairage::Bool : Présence d'un éclairage

lignes_desservies::String : Lignes de bus qui desservent cet arrêt

3. DonneesFrequentation
Contient les données de fréquentation en temps réel d'un arrêt spécifique.

Champs :

id::Int : Identifiant unique de l'enregistrement

date::Date : Date de l'observation

heure::Int : Heure de l'observation (format 24h)

ligne_id::Int : Référence à l'ID de la ligne de bus

arret_id::Int : Référence à l'ID de l'arrêt

montees::Int : Nombre de passagers montés à cet arrêt

descentes::Int : Nombre de passagers descendus à cet arrêt

occupation_bus::Int : Nombre de passagers dans le bus après l'arrêt

capacite_bus::Int : Capacité maximale du bus

4. Recommendation
Représente une recommandation d'optimisation pour une ligne de bus.

Champs :

ligne_id::Int : ID de la ligne concernée

nom_ligne::String : Nom de la ligne

frequence_actuelle::Int : Fréquence actuelle en minutes

frequence_recommandee::Int : Fréquence recommandée en minutes

taux_occupation_moyen::Float64 : Taux d'occupation moyen observé

gain_efficacite::Float64 : Gain d'efficacité estimé

raison::String : Justification de la recommandation

Utilisation typique
julia
using .TypesSotraco

# Création d'une ligne de bus
ligne = LigneBus(1, "Ligne 12", "Centre-ville", "Banlieue Nord", 15.5, 45, 500, 10, "Active")

# Création d'un arrêt
arret = Arret(1, "Place Centrale", "Centre", "Zone A", 4.5, 11.2, true, true, "Ligne 12, Ligne 15")
Notes techniques
Toutes les structures sont immuables (immutable structs)

Le module utilise le préfixe TypesSotraco pour éviter les conflits de noms

Les structures sont conçues pour être utilisées avec DataFrames pour l'analyse de données

Les coordonnées géographiques suivent le système standard (latitude, longitude)

Ce module sert de fondation pour un système de gestion de transport en commun, permettant le suivi des lignes, arrêts, fréquentations et l'optimisation des services.

"""

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