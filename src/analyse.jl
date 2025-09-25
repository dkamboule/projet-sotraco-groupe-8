"""
Documentation du module Analyse.jl
Vue d'ensemble
Le module Analyse fournit des fonctions pour analyser les données de fréquentation des transports en commun.
Il permet de calculer des statistiques générales, d'identifier les lignes critiques et d'analyser les heures de pointe.

Fonctions exportées
analyser_frequentation(df_frequentation::DataFrame, df_lignes::DataFrame)
Analyse complète des données de fréquentation des transports.

Paramètres:

df_frequentation : DataFrame contenant les données de fréquentation avec colonnes requises

df_lignes : DataFrame contenant les informations sur les lignes de transport

Colonnes requises dans df_frequentation:

heure : Heure de l'observation (Time ou Integer)

montees : Nombre de montées à l'arrêt

descentes : Nombre de descentes à l'arrêt

occupation_bus : Occupation actuelle du bus

capacite_bus : Capacité maximale du bus

ligne_id : Identifiant de la ligne

Retourne:
Un dictionnaire contenant:

total_passagers : Nombre total de passagers

moyenne_montees_par_arret : Moyenne des montées par arrêt

moyenne_descentes_par_arret : Moyenne des descentes par arrêt

occupation_moyenne : Taux d'occupation moyen des bus

occupation_par_ligne : Statistiques d'occupation par ligne

frequentation_horaire : Fréquentation par catégorie horaire

Exemple:

julia
resultats = analyser_frequentation(df_freq, df_lignes)
println("Total passagers: ", resultats["total_passagers"])
identifier_lignes_critiques(df_frequentation::DataFrame, df_lignes::DataFrame; seuil_occupation=0.75)
Identifie les lignes avec un taux d'occupation critique.

Paramètres:

df_frequentation : DataFrame des données de fréquentation

df_lignes : DataFrame des informations des lignes

seuil_occupation (optionnel) : Seuil critique (défaut: 0.75)

Retourne:
Un DataFrame trié des lignes critiques avec colonnes:

ligne_id : Identifiant de la ligne

taux_occupation_moyen : Taux d'occupation moyen

nom_ligne : Nom de la ligne (si présent dans df_lignes)

Exemple:
lignes_critiques = identifier_lignes_critiques(df_freq, df_lignes, seuil_occupation=0.8)

analyser_heures_pointe(df_frequentation::DataFrame)
Analyse les heures de pointe pour les montées et descentes.

Paramètres:

df_frequentation : DataFrame des données de fréquentation

Retourne:
Un tuple contenant deux DataFrames:

heures_pointe_montees : Top 3 des heures avec le plus de montées

heures_pointe_descentes : Top 3 des heures avec le plus de descentes

Exemple:
pointe_montees, pointe_descentes = analyser_heures_pointe(df_freq)

Catégories horaires
La fonction analyser_frequentation utilise les catégories horaires suivantes:

Matin : 6h-9h

Avant-midi : 9h-12h

Après-midi : 12h-16h

Soir : 16h-19h

Nuit : 19h-23h et 0h-6h

Dépendances
DataFrames : Manipulation des données tabulaires

Dates : Gestion des dates et heures

Statistics : Calculs statistiques de base

Notes d'utilisation
La colonne heure est automatiquement convertie en entier si elle est de type Time

Les valeurs manquantes dans le taux d'occupation sont ignorées dans les calculs

Les fonctions gèrent les erreurs de conversion de types pour la catégorisation horaire

Les résultats sont triés par ordre décroissant d'occupation pour faciliter l'analyse

Exemple complet:

using DataFrames
using .Analyse

# Chargement des données
df_freq = DataFrame(...)
df_lignes = DataFrame(...)

# Analyse complète
resultats = analyser_frequentation(df_freq, df_lignes)

# Identification des lignes critiques
lignes_critiques = identifier_lignes_critiques(df_freq, df_lignes)

# Analyse des heures de pointe
heures_pointe = analyser_heures_pointe(df_freq)
"""
# analyse.jl - Analyse des données
module Analyse
using DataFrames, Dates, Statistics

export analyser_frequentation, identifier_lignes_critiques, analyser_heures_pointe

function analyser_frequentation(df_frequentation::DataFrame, df_lignes::DataFrame)
    resultats = Dict()
    
    # Vérification et conversion de l'heure si nécessaire
    if hasproperty(df_frequentation, :heure)
        println("Type de la colonne heure: ", eltype(df_frequentation.heure))
        if eltype(df_frequentation.heure) <: Time
            df_frequentation.heure = hour.(df_frequentation.heure)
        end
    end
    
    # Statistiques générales
    resultats["total_passagers"] = sum(df_frequentation.montees)
    resultats["moyenne_montees_par_arret"] = mean(df_frequentation.montees)
    resultats["moyenne_descentes_par_arret"] = mean(df_frequentation.descentes)
    
    # Occupation moyenne des bus
    df_frequentation.taux_occupation = df_frequentation.occupation_bus ./ df_frequentation.capacite_bus
    resultats["occupation_moyenne"] = mean(skipmissing(df_frequentation.taux_occupation))
    
    # Analyse par ligne
    occupation_par_ligne = combine(
        groupby(df_frequentation, :ligne_id),
        :montees => sum => :total_montees,
        :descentes => sum => :total_descentes,
        :taux_occupation => mean => :occupation_moyenne
    )
    
    # Fusion avec les noms des lignes
    occupation_par_ligne = leftjoin(occupation_par_ligne, df_lignes[:, [:id, :nom_ligne]], on=:ligne_id => :id)
    
    resultats["occupation_par_ligne"] = occupation_par_ligne
    
    # Analyse horaire - Fonction de catégorisation manuelle
    function categoriser_heure(heure)
        try
            # Convertir en entier si ce n'est pas déjà le cas
            h = typeof(heure) <: Integer ? heure : parse(Int, string(heure))
            
            if 6 <= h < 9
                return "Matin"
            elseif 9 <= h < 12
                return "Avant-midi"
            elseif 12 <= h < 16
                return "Après-midi"
            elseif 16 <= h < 19
                return "Soir"
            elseif 19 <= h <= 23
                return "Nuit"
            else
                return "Nuit"
            end
        catch e
            return "Inconnu"
        end
    end
    
    df_frequentation.heure_categorie = [categoriser_heure(h) for h in df_frequentation.heure]
    frequentation_horaire = combine(
        groupby(df_frequentation, :heure_categorie),
        :montees => sum => :montees_total,
        :descentes => sum => :descentes_total
    )
    
    resultats["frequentation_horaire"] = frequentation_horaire
    
    return resultats
end

function identifier_lignes_critiques(df_frequentation::DataFrame, df_lignes::DataFrame; seuil_occupation=0.75)
    # Calcul du taux d'occupation par ligne
    df_frequentation.taux_occupation = df_frequentation.occupation_bus ./ df_frequentation.capacite_bus
    occupation_par_ligne = combine(
        groupby(df_frequentation, :ligne_id),
        :taux_occupation => mean => :taux_occupation_moyen
    )
    
    # Fusion avec les données des lignes
    occupation_par_ligne = leftjoin(occupation_par_ligne, df_lignes, on=:ligne_id => :id)
    
    # Filtrage des lignes critiques
    lignes_critiques = filter(row -> row.taux_occupation_moyen >= seuil_occupation, occupation_par_ligne)
    
    return sort(lignes_critiques, :taux_occupation_moyen, rev=true)
end

function analyser_heures_pointe(df_frequentation::DataFrame)
    # Vérification et conversion de l'heure si nécessaire
    if hasproperty(df_frequentation, :heure) && eltype(df_frequentation.heure) <: Time
        df_frequentation.heure = hour.(df_frequentation.heure)
    end
    
    # Analyse des heures de pointe
    frequentation_par_heure = combine(
        groupby(df_frequentation, :heure),
        :montees => sum => :montees_total,
        :descentes => sum => :descentes_total
    )
    
    # Identification des heures de pointe (top 3)
    heures_pointe_montees = sort(frequentation_par_heure, :montees_total, rev=true)[1:3, :]
    heures_pointe_descentes = sort(frequentation_par_heure, :descentes_total, rev=true)[1:3, :]
    
    return (heures_pointe_montees = heures_pointe_montees, 
            heures_pointe_descentes = heures_pointe_descentes)
end

end