"""
Documentation du Fichier main.jl
Description
main.jl est le point d'entrée principal du projet SOTRACO (Simulateur de Transport). 
Ce fichier orchestre l'exécution complète du système d'analyse et d'optimisation des transports en commun.

Structure du Fichier
1. Importations et Inclusions

using DataFrames, CSV, Dates, Statistics, Plots, Printf
include("types.jl")
include("io_operations.jl")
include("optimisation.jl")
include("analyse.jl")
include("visualisation.jl")
include("rapports.jl")
using .IOOperations: charger_lignes_bus, charger_arrets, charger_frequentation, sauvegarder_recommandations
using .Optimisation: optimiser_frequences, calculer_temps_attente, evaluer_impact_optimisation
using .Analyse: analyser_frequentation, identifier_lignes_critiques, analyser_heures_pointe
using .Visualisation: creer_visualisations, plot_occupation_par_ligne, plot_frequentation_horaire
using .Rapports: generer_rapport_complet, generer_rapport_ligne
2. Fonction Principale main()
La fonction principale qui coordonne l'ensemble du processus d'analyse.

Flux d'exécution :
Chargement des données depuis les fichiers CSV

Diagnostic des types de données pour vérifier l'intégrité

Analyse de la fréquentation des bus

Identification des lignes critiques nécessitant une optimisation urgente

Optimisation des fréquences de passage

Génération de rapports détaillés

Création de visualisations graphiques

Sauvegarde des recommandations d'optimisation

3. Gestion des Erreurs
Le code inclut un bloc try-catch robuste pour :

Gérer les erreurs de chargement des fichiers

Fournir des messages d'erreur explicites

Guider l'utilisateur sur la structure attendue des fichiers

4. Exécution Conditionnelle

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
Cette condition assure que la fonction main() ne s'exécute que lorsque le fichier est lancé directement (et non lorsqu'il est importé comme module).

Fonctionnalités Principales
Chargement des Données
charger_lignes_bus() : Charge les informations sur les lignes de bus

charger_arrets() : Charge la liste des arrêts

charger_frequentation() : Charge les données de fréquentation

Analyse
analyser_frequentation() : Analyse statistique de la fréquentation

identifier_lignes_critiques() : Identifie les lignes surchargées

Optimisation
optimiser_frequences() : Calcule les fréquences optimales

sauvegarder_recommandations() : Sauvegarde les résultats

Visualisation et Reporting
creer_visualisations() : Génère les graphiques

generer_rapport_complet() : Produit le rapport détaillé

Fichiers de Données Requis
data/lignes_bus.csv : Informations sur les lignes de bus

data/arrets.csv : Liste des arrêts avec leurs coordonnées

data/frequentation.csv : Données historiques de fréquentation

Sorties Générées
Rapports textuels dans le dossier rapports/

Visualisations graphiques

Fichier CSV des recommandations d'optimisation
"""
# main.jl - Point d'entrée principal du projet
using DataFrames, CSV, Dates, Statistics, Plots, Printf

# Inclusion des modules
include("types.jl")
include("io_operations.jl")
include("optimisation.jl")
include("analyse.jl")
include("visualisation.jl")
include("rapports.jl")

# Importation des fonctions nécessaires
using .IOOperations: charger_lignes_bus, charger_arrets, charger_frequentation, sauvegarder_recommandations
using .Optimisation: optimiser_frequences, calculer_temps_attente, evaluer_impact_optimisation
using .Analyse: analyser_frequentation, identifier_lignes_critiques, analyser_heures_pointe
using .Visualisation: creer_visualisations, plot_occupation_par_ligne, plot_frequentation_horaire
using .Rapports: generer_rapport_complet, generer_rapport_ligne

function main()
    println("=== Simulateur de Transport SOTRACO ===")
    println("Chargement des données...")
    
    # Chargement des données depuis les fichiers CSV
    try
        df_lignes = charger_lignes_bus("data/lignes_bus.csv")
        df_arrets = charger_arrets("data/arrets.csv")
        df_frequentation = charger_frequentation("data/frequentation.csv")
        
        println("✓ Données chargées avec succès")
        println("Lignes de bus: ", nrow(df_lignes))
        println("Arrêts: ", nrow(df_arrets))
        println("Enregistrements de fréquentation: ", nrow(df_frequentation))
        
        # Diagnostic des types de données
        println("\nDiagnostic des types de données:")
        println("Colonnes frequentation: ", names(df_frequentation))
        println("Type de la colonne 'heure': ", eltype(df_frequentation.heure))
        println("Premières valeurs de 'heure': ", first(df_frequentation.heure, 5))
        
        # Analyse des données
        println("\n=== ANALYSE DES DONNÉES ===")
        analyse_resultats = analyser_frequentation(df_frequentation, df_lignes)
        
        # Identification des lignes critiques
        lignes_critiques = identifier_lignes_critiques(df_frequentation, df_lignes)
        println("\nLignes nécessitant une optimisation urgente:")
        for ligne in eachrow(lignes_critiques)
            println("- ", ligne.nom_ligne, " (Occupation: ", @sprintf("%.1f%%", ligne.taux_occupation_moyen * 100), ")")
        end
        
        # Optimisation des fréquences
        println("\n=== OPTIMISATION DES FRÉQUENCES ===")
        recommendations = optimiser_frequences(df_frequentation, df_lignes)
        
        # Génération de rapports
        println("\n=== GÉNÉRATION DE RAPPORTS ===")
        generer_rapport_complet(df_lignes, df_arrets, df_frequentation, recommendations)
        
        # Visualisations
        println("\n=== CRÉATION DE VISUALISATIONS ===")
        creer_visualisations(df_lignes, df_frequentation, recommendations)
        
        # Sauvegarde des recommandations
        sauvegarder_recommandations(recommendations, "rapports/recommandations_optimisation.csv")
        
        println("\n=== PROJET TERMINÉ AVEC SUCCÈS ===")
        
    catch e
        println("❌ Erreur lors du traitement des données: ", e)
        println("Stacktrace: ")
        showerror(stdout, e)
        println("\nAssurez-vous que les fichiers CSV sont dans le dossier 'data/' avec les noms corrects:")
        println("- data/lignes_bus.csv")
        println("- data/arrets.csv") 
        println("- data/frequentation.csv")
    end
end

# Exécution du programme principal
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end