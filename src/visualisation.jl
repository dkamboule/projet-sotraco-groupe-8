# visualisation.jl - Visualisation des données
module Visualisation
using DataFrames, Plots, StatsPlots, Statistics, Printf  # Ajout de StatsPlots

export creer_visualisations, plot_occupation_par_ligne, plot_frequentation_horaire

function creer_visualisations(df_lignes::DataFrame, df_frequentation::DataFrame, recommendations)
    println("Création des visualisations...")
    
    # Création du dossier de sortie s'il n'existe pas
    if !isdir("visualisations")
        mkdir("visualisations")
    end
    
    # 1. Occupation par ligne
    p1 = plot_occupation_par_ligne(df_frequentation, df_lignes)
    savefig(p1, "visualisations/occupation_par_ligne.png")
    
    # 2. Fréquentation horaire
    p2 = plot_frequentation_horaire(df_frequentation)
    savefig(p2, "visualisations/frequentation_horaire.png")
    
    # 3. Recommendations d'optimisation
    p3 = plot_recommandations(recommendations)
    savefig(p3, "visualisations/recommandations_optimisation.png")
    
    println("Visualisations sauvegardées dans le dossier 'visualisations'")
end

function plot_occupation_par_ligne(df_frequentation::DataFrame, df_lignes::DataFrame)
    # Calcul de l'occupation moyenne par ligne
    df_frequentation.taux_occupation = df_frequentation.occupation_bus ./ df_frequentation.capacite_bus
    occupation_par_ligne = combine(
        groupby(df_frequentation, :ligne_id),
        :taux_occupation => mean => :occupation_moyenne
    )
    
    # Fusion avec les noms des lignes
    occupation_par_ligne = leftjoin(occupation_par_ligne, df_lignes[:, [:id, :nom_ligne]], on=:ligne_id => :id)
    
    p = bar(occupation_par_ligne.nom_ligne, occupation_par_ligne.occupation_moyenne .* 100,
            xrot=45,
            alpha=0.25,
            title="Taux d'occupation moyen par ligne",
            xlabel="Lignes de bus",
            ylabel="Occupation (%)",
            legend=false,
            color=:blue,
            ylim=(0, 100))
    
    # Ajout des valeurs sur les barres
    for (i, val) in enumerate(occupation_par_ligne.occupation_moyenne .* 100)
        annotate!(i, val + 2, text(Printf.@sprintf("%.1f%%", val), 5))
    end
    
    return p
end

function plot_frequentation_horaire(df_frequentation::DataFrame)
    frequentation_par_heure = combine(
        groupby(df_frequentation, :heure),
        :montees => sum => :montees_total,
        :descentes => sum => :descentes_total
    )
    
    # Trier par heure pour un tracé correct
    sort!(frequentation_par_heure, :heure)
    
    p = plot(frequentation_par_heure.heure, frequentation_par_heure.montees_total,
             label="Montées", linewidth=2, marker=:circle,
             xlabel="Heure de la journée", ylabel="Nombre de passagers",
             title="Fréquentation horaire des bus")
    
    plot!(frequentation_par_heure.heure, frequentation_par_heure.descentes_total,
          label="Descentes", linewidth=2, marker=:square)
    
    return p
end

function plot_recommandations(recommendations)
    noms_lignes = [r.nom_ligne for r in recommendations]
    freq_actuelles = [r.frequence_actuelle for r in recommendations]
    freq_recommandees = [r.frequence_recommandee for r in recommendations]
    
    p = groupedbar([freq_actuelles freq_recommandees],
                   group=noms_lignes,
                   #label=["Fréquence actuelle" "Fréquence recommandée"],
                   title="Recommandations d'optimisation des fréquences",
                   xlabel="Lignes de bus",
                   ylabel="Fréquence (minutes)")
                   
    
    return p
end

end