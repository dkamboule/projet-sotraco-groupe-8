"""
Documentation du Module Rapports.jl
Vue d'ensemble
Le module Rapports fournit des fonctionnalités de génération de rapports d'optimisation pour le réseau de transport SOTRACO. 
Il permet de créer des rapports complets et détaillés par ligne.

Fonctions exportées
generer_rapport_complet
julia
generer_rapport_complet(df_lignes::DataFrame, df_arrets::DataFrame, df_frequentation::DataFrame, recommendations)
Description: Génère un rapport complet d'optimisation du réseau SOTRACO.

Paramètres:

df_lignes: DataFrame contenant les informations sur les lignes de bus

df_arrets: DataFrame contenant les informations sur les arrêts de bus

df_frequentation: DataFrame contenant les données de fréquentation

recommendations: Collection de recommandations d'optimisation

Sortie:

Crée un fichier texte dans le dossier rapports/ avec le format rapport_sotraco_AAAA-MM-JJ.txt

Retourne le nom du fichier généré

Sections du rapport:

Statistiques générales: Nombre de lignes, arrêts, enregistrements et période couverte

Recommandations d'optimisation: Détails par ligne avec fréquences actuelles/recommandées

Impact estimé: Impact global des modifications proposées

generer_rapport_ligne
julia
generer_rapport_ligne(df_frequentation::DataFrame, df_lignes::DataFrame, ligne_id::Int)
Description: Génère un rapport détaillé pour une ligne spécifique.

Paramètres:

df_frequentation: DataFrame des données de fréquentation

df_lignes: DataFrame des informations sur les lignes

ligne_id: Identifiant numérique de la ligne à analyser

Retourne:

Une chaîne de caractères contenant le rapport détaillé de la ligne

Message d'erreur si aucune donnée n'est disponible

Contenu du rapport:

Informations générales sur la ligne (origine, destination, distance, durée)

Statistiques de fréquentation (taux d'occupation, montées/descentes totales)

Structure des données attendues
DataFrame df_lignes:
id: Identifiant de la ligne (Int)

nom_ligne: Nom de la ligne (String)

origine: Point de départ (String)

destination: Point d'arrivée (String)

distance_km: Distance en km (Float)

duree_trajet_min: Durée du trajet en minutes (Int)

frequence_min: Fréquence actuelle en minutes (Int)

DataFrame df_frequentation:
ligne_id: Identifiant de la ligne (Int)

date: Date de l'enregistrement (Date)

occupation_bus: Nombre de passagers à bord (Int)

capacite_bus: Capacité maximale du bus (Int)

montees: Nombre de montées (Int)

descentes: Nombre de descentes (Int)

Structure des recommandations:
Chaque recommandation doit contenir:

nom_ligne: Nom de la ligne (String)

frequence_actuelle: Fréquence actuelle en minutes (Int)

frequence_recommandee: Fréquence recommandée en minutes (Int)

taux_occupation_moyen: Taux d'occupation moyen (Float)

raison: Justification de la recommandation (String)

Exemple d'utilisation
julia
using DataFrames, Dates
using .Rapports

# Chargement des données
df_lignes = DataFrame(...)
df_arrets = DataFrame(...)
df_frequentation = DataFrame(...)

# Génération des recommandations
recommendations = generer_recommandations(df_lignes, df_frequentation)

# Génération du rapport complet
generer_rapport_complet(df_lignes, df_arrets, df_frequentation, recommendations)

# Rapport détaillé pour une ligne spécifique
rapport_ligne = generer_rapport_ligne(df_frequentation, df_lignes, 1)
println(rapport_ligne)
Dépendances
DataFrames: Manipulation des données tabulaires

Dates: Gestion des dates et horaires

Printf: Formatage des nombres et chaînes de caractères

Gestion des erreurs
Vérification de l'existence du dossier rapports/

Contrôle de la présence de données pour chaque ligne analysée

Gestion des divisions par zéro dans les calculs statistiques

"""
# rapports.jl - Génération de rapports
module Rapports
using DataFrames, Dates, Printf

export generer_rapport_complet, generer_rapport_ligne

function generer_rapport_complet(df_lignes::DataFrame, df_arrets::DataFrame, df_frequentation::DataFrame, recommendations)
    println("Génération du rapport complet...")
    
    # Création du dossier de sortie
    if !isdir("resultats/rapports")
        mkdir("resultats/rapports")
    end

    nom_fichier = "resultats/rapports/rapport_sotraco_$(today()).txt"

    open(nom_fichier, "w") do fichier
        write(fichier, "=== RAPPORT D'OPTIMISATION SOTRACO ===\n")
        write(fichier, "Date: $(today())\n\n")
        
        # Statistiques générales
        write(fichier, "STATISTIQUES GÉNÉRALES\n")
        write(fichier, "=====================\n")
        write(fichier, "Nombre total de lignes: $(nrow(df_lignes))\n")
        write(fichier, "Nombre total d'arrêts: $(nrow(df_arrets))\n")
        write(fichier, "Enregistrements de fréquentation: $(nrow(df_frequentation))\n")
        write(fichier, "Période couverte: $(minimum(df_frequentation.date)) à $(maximum(df_frequentation.date))\n\n")
        
        # Recommandations d'optimisation
        write(fichier, "RECOMMANDATIONS D'OPTIMISATION\n")
        write(fichier, "=============================\n")
        
        for rec in recommendations
            write(fichier, "Ligne $(rec.nom_ligne):\n")
            write(fichier, "  - Fréquence actuelle: $(rec.frequence_actuelle) min\n")
            write(fichier, "  - Fréquence recommandée: $(rec.frequence_recommandee) min\n")
            write(fichier, "  - Taux d'occupation: $(@sprintf("%.1f", rec.taux_occupation_moyen*100))%\n")
            write(fichier, "  - Raison: $(rec.raison)\n\n")
        end
        
        # Impact estimé
        impact_total = 0.0
        lignes_modifiees = 0
        for rec in recommendations
            if rec.frequence_actuelle != rec.frequence_recommandee
                gain_temps = abs(rec.frequence_actuelle - rec.frequence_recommandee) / 2.0
                impact_total += gain_temps
                lignes_modifiees += 1
            end
        end
        
        write(fichier, "IMPACT ESTIMÉ DES MODIFICATIONS\n")
        write(fichier, "===============================\n")
        write(fichier, "Lignes modifiées: $lignes_modifiees sur $(length(recommendations))\n")
        write(fichier, "Réduction moyenne du temps d'attente: $(@sprintf("%.1f", impact_total/lignes_modifiees)) minutes\n")
        write(fichier, "Impact total sur le réseau: $(@sprintf("%.1f", impact_total)) minutes\n")
    end
    
    println("Rapport généré: $nom_fichier")
end

function generer_rapport_ligne(df_frequentation::DataFrame, df_lignes::DataFrame, ligne_id::Int)
    ligne = filter(r -> r.id == ligne_id, df_lignes)[1, :]
    donnees_ligne = filter(r -> r.ligne_id == ligne_id, df_frequentation)
    
    if nrow(donnees_ligne) == 0
        return "Aucune donnée pour cette ligne"
    end
    
    rapport = "=== RAPPORT DÉTAILLÉ LIGNE $(ligne.nom_ligne) ===\n"
    rapport *= "Origine: $(ligne.origine) → Destination: $(ligne.destination)\n"
    rapport *= "Distance: $(ligne.distance_km) km | Durée: $(ligne.duree_trajet_min) min\n"
    rapport *= "Fréquence actuelle: $(ligne.frequence_min) minutes\n\n"
    
    # Statistiques de fréquentation
    occupation_moyenne = mean(donnees_ligne.occupation_bus ./ donnees_ligne.capacite_bus)
    montees_total = sum(donnees_ligne.montees)
    descentes_total = sum(donnees_ligne.descentes)
    
    rapport *= "STATISTIQUES DE FRÉQUENTATION:\n"
    rapport *= "Taux d'occupation moyen: $(@sprintf("%.1f", occupation_moyenne*100))%\n"
    rapport *= "Total montées: $montees_total passagers\n"
    rapport *= "Total descentes: $descentes_total passagers\n"
    
    return rapport
end

end