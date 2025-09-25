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
        sauvegarder_recommandations(recommendations, "resultats/rapports/recommandations_optimisation.csv")
        
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