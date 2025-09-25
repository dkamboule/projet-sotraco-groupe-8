# visualisation.jl - Visualisation des données
module Visualisation
using DataFrames, Plots, StatsPlots, Statistics, Printf  # Ajout de StatsPlots

export creer_visualisations, plot_occupation_par_ligne, plot_frequentation_horaire

function creer_visualisations(df_lignes::DataFrame, df_frequentation::DataFrame, recommendations)
    println("Création des visualisations...")
    
    # Création du dossier de sortie s'il n'existe pas
    if !isdir("resultats/visualisations")
        mkdir("resultats/visualisations")
    end
    
    # 1. Occupation par ligne
    p1 = plot_occupation_par_ligne(df_frequentation, df_lignes)
    savefig(p1, "resultats/visualisations/occupation_par_ligne.png")
    
    # 2. Fréquentation horaire
    p2 = plot_frequentation_horaire(df_frequentation)
    savefig(p2, "resultats/visualisations/frequentation_horaire.png")

    # 3. Recommendations d'optimisation
    p3 = plot_recommandations(recommendations)
    savefig(p3, "resultats/visualisations/recommandations_optimisation.png")

    println("Visualisations sauvegardées dans le dossier 'resultats/visualisations'")
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
    
    sort!(frequentation_par_heure, :heure)
    
    p = plot(size=(1200, 800), dpi=150, legend=:topright)
    
    # Aire sous la courbe pour les montées (très visible)
    plot!(frequentation_par_heure.heure, frequentation_par_heure.montees_total,
          label="Montées", 
          fillrange=0,                    # Remplissage jusqu'à l'axe x
          fillalpha=0.3,                  # Transparence du remplissage
          linewidth=3,
          marker=:circle,
          markersize=6,
          color=:blue,
          xlabel="Heure de la journée", 
          ylabel="Nombre de passagers",
          title="Fréquentation horaire des bus")
    
    # Aire sous la courbe pour les descentes
    plot!(frequentation_par_heure.heure, frequentation_par_heure.descentes_total,
          label="Descentes",
          fillrange=0,
          fillalpha=0.3,
          linewidth=3,
          marker=:square,
          markersize=6,
          color=:red)
    
    # Ajustement des limites
    y_max = max(maximum(frequentation_par_heure.montees_total), 
                maximum(frequentation_par_heure.descentes_total))
    ylims!(0, y_max * 1.1)
    xticks!(frequentation_par_heure.heure)
    
    return p
end

function plot_recommandations(recommendations)
    noms_lignes = [r.nom_ligne for r in recommendations]
    freq_actuelles = [r.frequence_actuelle for r in recommendations]
    freq_recommandees = [r.frequence_recommandee for r in recommendations]
    
    # Calcul du nombre de lignes pour ajuster la hauteur
    n_lignes = length(noms_lignes)
    hauteur = max(600, n_lignes * 40)  # Hauteur adaptative
    
    p = plot(size=(1400, hauteur), dpi=150)
    
    # Positionnement manuel pour éviter les chevauchements
    bar_plot = groupedbar([freq_actuelles freq_recommandees],
                         group=noms_lignes,
                         label=["Fréquence actuelle" "Fréquence recommandée"],
                         title="Recommandations d'optimisation des fréquences",
                         xlabel="Lignes de bus",
                         ylabel="Fréquence (minutes)",
                         legend=:outertopright,  # Légende à l'extérieur
                         xtickfontsize=9,
                         ytickfontsize=10,
                         xguidefontsize=12,
                         yguidefontsize=12,
                         titlefontsize=16,
                         legendfontsize=6,
                         grid=true,
                         framestyle=:box)
    
    # Rotation des labels x si nécessaire
    if any(length.(noms_lignes) .> 15)
        bar_plot = groupedbar([freq_actuelles freq_recommandees],
                             group=noms_lignes,
                             label=["Actuelle" "Recommandée"],  # Labels courts
                             title="Recommandations d'optimisation des fréquences",
                             xlabel="Lignes de bus",
                            ylabel="Fréquence (minutes)",
                             legend=:topright,
                             xrotation=45,
                             size=(1200, 800))
    end
    
    return bar_plot
end
end # module