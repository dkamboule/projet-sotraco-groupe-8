"""
Documentation du module Visualisation.jl
Vue d'ensemble
Le module Visualisation fournit des fonctions pour créer des visualisations graphiques à partir des données de fréquentation des bus. 
Il génère des graphiques d'analyse et des recommandations d'optimisation.

Fonctions exportées
creer_visualisations(df_lignes::DataFrame, df_frequentation::DataFrame, recommendations)
Description principale: Fonction principale qui orchestre la création de toutes les visualisations.

Paramètres:

df_lignes::DataFrame - DataFrame contenant les informations sur les lignes de bus (id, nom_ligne)

df_frequentation::DataFrame - DataFrame contenant les données de fréquentation horaire

recommendations - Structure de données contenant les recommandations d'optimisation

Actions:

Crée le dossier "visualisations" s'il n'existe pas

Génère trois graphiques différents

Sauvegarde les visualisations au format PNG

Affiche un message de confirmation

Retourne: Rien (effet de bord - création de fichiers)

Exemple:


# Charger les données
df_lignes = DataFrame(id=1:3, nom_ligne=["Ligne A", "Ligne B", "Ligne C"])
df_frequentation = DataFrame(
    ligne_id=repeat(1:3, inner=4),
    heure=repeat(8:11, outer=3),
    occupation_bus=rand(40:80, 12),
    capacite_bus=repeat([80], 12),
    montees=rand(10:30, 12),
    descentes=rand(5:25, 12)
)

# Créer des recommandations factices
recommendations = [
    (nom_ligne="Ligne A", frequence_actuelle=15, frequence_recommandee=10),
    (nom_ligne="Ligne B", frequence_actuelle=20, frequence_recommandee=15),
    (nom_ligne="Ligne C", frequence_actuelle=30, frequence_recommandee=20)
]

# Générer les visualisations
Visualisation.creer_visualisations(df_lignes, df_frequentation, recommendations)
plot_occupation_par_ligne(df_frequentation::DataFrame, df_lignes::DataFrame)
Description: Crée un diagramme en barres montrant le taux d'occupation moyen par ligne de bus.

Paramètres:

df_frequentation::DataFrame - Données de fréquentation avec occupation et capacité

df_lignes::DataFrame - Informations sur les lignes pour obtenir les noms

Calculs:

Calcule le taux d'occupation (occupation_bus / capacite_bus)

Agrège par moyenne par ligne_id

Fusionne avec les noms des lignes

Retourne: Un objet Plot (graphique à barres) avec:

Noms des lignes en abscisse

Taux d'occupation en pourcentage en ordonnée

Valeurs annotées sur chaque barre

Exemple:

df_lignes = DataFrame(id=1:3, nom_ligne=["Ligne A", "Ligne B", "Ligne C"])
df_frequentation = DataFrame(
    ligne_id=repeat(1:3, inner=4),
    occupation_bus=rand(40:80, 12),
    capacite_bus=repeat([80], 12)
)

p = Visualisation.plot_occupation_par_ligne(df_frequentation, df_lignes)
display(p)
plot_frequentation_horaire(df_frequentation::DataFrame)
Description: Crée un graphique linéaire montrant l'évolution de la fréquentation au cours de la journée.

Paramètres:

df_frequentation::DataFrame - Données de fréquentation avec montées et descentes par heure

Calculs:

Agrège les montées et descentes par heure

Trie les données par heure pour un tracé correct

Retourne: Un objet Plot (graphique linéaire) avec:

Heures en abscisse

Nombre de passagers en ordonnée

Deux courbes: montées (cercles) et descentes (carrés)

Exemple:


df_frequentation = DataFrame(
    heure=repeat(8:11, outer=3),
    montees=rand(10:30, 12),
    descentes=rand(5:25, 12)
)

p = Visualisation.plot_frequentation_horaire(df_frequentation)
display(p)
plot_recommandations(recommendations)
Description: Crée un diagramme en barres groupées comparant les fréquences actuelles et recommandées.

Paramètres:

recommendations - Structure contenant les données de recommandations (doit avoir les champs: nom_ligne, frequence_actuelle, frequence_recommandee)

Retourne: Un objet Plot (barres groupées) avec:

Lignes de bus en abscisse

Fréquence en minutes en ordonnée

Barres groupées montrant fréquences actuelles vs recommandées

Exemple:


recommendations = [
    (nom_ligne="Ligne A", frequence_actuelle=15, frequence_recommandee=10),
    (nom_ligne="Ligne B", frequence_actuelle=20, frequence_recommandee=15),
    (nom_ligne="Ligne C", frequence_actuelle=30, frequence_recommandee=20)
]

p = Visualisation.plot_recommandations(recommendations)
display(p)
Dépendances
DataFrames - Manipulation des données tabulaires

Plots - Création de graphiques

StatsPlots - Graphiques statistiques supplémentaires

Statistics - Fonctions statistiques de base

Printf - Formatage des annotations

Structure des données attendues
df_lignes: Doit contenir les colonnes:

id - Identifiant de la ligne

nom_ligne - Nom affichable de la ligne

df_frequentation: Doit contenir les colonnes:

ligne_id - Identifiant de la ligne

heure - Heure de la mesure

occupation_bus - Nombre de passagers à bord

capacite_bus - Capacité maximale du bus

montees - Passagers montants

descentes - Passagers descendants

recommendations: Doit être un tableau d'objets avec:

nom_ligne - Nom de la ligne

frequence_actuelle - Fréquence actuelle en minutes

frequence_recommandee - Fréquence recommandée en minutes

"""
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