"""
Documentation du module IOOperations.jl
Vue d'ensemble
Le module IOOperations fournit des fonctions utilitaires pour les opérations d'entrée/sortie liées à la gestion des données de transport en commun. 
permet de charger différents types de données (lignes de bus, arrêts, fréquentation) et de sauvegarder les recommandations générées par le système.

Fonctions exportées
charger_lignes_bus(chemin_fichier::String)
Charge les données des lignes de bus à partir d'un fichier CSV.

Paramètres:

chemin_fichier (String) : Chemin vers le fichier CSV contenant les données des lignes de bus

Retourne:

DataFrame : DataFrame contenant les données des lignes de bus

Lève une exception:

Si le fichier n'est pas trouvé

charger_arrets(chemin_fichier::String)
Charge les données des arrêts de bus à partir d'un fichier CSV.

Paramètres:

chemin_fichier (String) : Chemin vers le fichier CSV contenant les données des arrêts

Retourne:

DataFrame : DataFrame contenant les données des arrêts

Lève une exception:

Si le fichier n'est pas trouvé

charger_frequentation(chemin_fichier::String)
Charge les données de fréquentation des bus avec conversions automatiques des types de données.

Fonctionnalités spéciales:

Convertit automatiquement les dates au format Date

Convertit les heures en format numérique (heures entières)

Gère différents formats d'heure (Time, String)

Paramètres:

chemin_fichier (String) : Chemin vers le fichier CSV contenant les données de fréquentation

Retourne:

DataFrame : DataFrame contenant les données de fréquentation avec types appropriés

Lève une exception:

Si le fichier n'est pas trouvé

sauvegarder_recommandations(recommandations, chemin_fichier::String)
Sauvegarde les recommandations générées dans un fichier CSV.

Paramètres:

recommandations : Collection d'objets recommandation (doit avoir les propriétés: ligne_id, nom_ligne, frequence_actuelle, frequence_recommandee, taux_occupation_moyen, gain_efficacite, raison)

chemin_fichier (String) : Chemin où sauvegarder le fichier CSV

Effets:

Crée un fichier CSV avec les recommandations

Affiche un message de confirmation

Dépendances
Le module utilise les packages suivants:

DataFrames : Pour la manipulation des données tabulaires

CSV : Pour la lecture/écriture des fichiers CSV

Dates : Pour la manipulation des dates et heures

Statistics : Pour les opérations statistiques

Gestion d'erreurs
Vérification systématique de l'existence des fichiers avant lecture

Gestion robuste des conversions de types avec messages d'avertissement

Messages d'erreur explicites en cas de problème

Exemple d'utilisation
julia
using .IOOperations

# Chargement des données
lignes = charger_lignes_bus("data/lignes.csv")
arrets = charger_arrets("data/arrets.csv")
frequentation = charger_frequentation("data/frequentation.csv")

# Sauvegarde des recommandations
sauvegarder_recommandations(recommandations, "output/recommandations.csv")

"""

# io_operations.jl - Opérations d'entrée/sortie
module IOOperations
using DataFrames, CSV, Dates, Statistics

export charger_lignes_bus, charger_arrets, charger_frequentation, sauvegarder_recommandations

function charger_lignes_bus(chemin_fichier::String)
    if isfile(chemin_fichier)
        df = CSV.read(chemin_fichier, DataFrame)
        return df
    else
        error("Fichier non trouvé: $chemin_fichier")
    end
end

function charger_arrets(chemin_fichier::String)
    if isfile(chemin_fichier)
        df = CSV.read(chemin_fichier, DataFrame)
        return df
    else
        error("Fichier non trouvé: $chemin_fichier")
    end
end

function charger_frequentation(chemin_fichier::String)
    if isfile(chemin_fichier)
        df = CSV.read(chemin_fichier, DataFrame)
        
        # Conversion des types si nécessaire
        if hasproperty(df, :date)
            try
                df.date = Date.(df.date)
            catch e
                println("Attention: Impossible de convertir la colonne date: ", e)
            end
        end
        
        if hasproperty(df, :heure)
            try
                # Si l'heure est au format Time, convertir en entier (heure de la journée)
                if eltype(df.heure) <: Time
                    df.heure = hour.(df.heure)
                elseif eltype(df.heure) <: String
                    # Si c'est une chaîne, essayer de parser
                    df.heure = parse.(Int, replace.(df.heure, ":" => ""))
                end
            catch e
                println("Attention: Conversion de l'heure échouée: ", e)
                println("Type de la colonne heure: ", eltype(df.heure))
            end
        end
        
        return df
    else
        error("Fichier non trouvé: $chemin_fichier")
    end
end

function sauvegarder_recommandations(recommandations, chemin_fichier::String)
    df = DataFrame(
        ligne_id = [r.ligne_id for r in recommandations],
        nom_ligne = [r.nom_ligne for r in recommandations],
        frequence_actuelle = [r.frequence_actuelle for r in recommandations],
        frequence_recommandee = [r.frequence_recommandee for r in recommandations],
        taux_occupation_moyen = [r.taux_occupation_moyen for r in recommandations],
        gain_efficacite = [r.gain_efficacite for r in recommandations],
        raison = [r.raison for r in recommandations]
    )
    
    CSV.write(chemin_fichier, df)
    println("Recommandations sauvegardées dans: $chemin_fichier")
end

end