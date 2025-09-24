"""
Documentation du Module Optimisation
Vue d'ensemble
Le module Optimisation fournit des algorithmes pour optimiser les fréquences des lignes de transport en commun basées sur les données de fréquentation. 
Il permet d'analyser l'occupation des bus et de recommander des ajustements de fréquence pour améliorer l'efficacité du réseau.

Fonctions exportées
optimiser_frequences(df_frequentation::DataFrame, df_lignes::DataFrame)
Description principale :
Analyse les données de fréquentation pour recommander des ajustements optimaux des fréquences de bus par ligne.

Paramètres :

df_frequentation : DataFrame contenant les données de fréquentation avec colonnes requises :

ligne_id : identifiant de la ligne

occupation_bus : niveau d'occupation du bus

capacite_bus : capacité maximale du bus

df_lignes : DataFrame contenant les informations des lignes avec colonnes requises :

id : identifiant de la ligne

nom_ligne : nom de la ligne

frequence_min : fréquence actuelle en minutes

Logique d'optimisation :

Surcharge (taux d'occupation > 80%) : Réduction de fréquence de 5 minutes (minimum 5 min)

Sous-utilisation (taux d'occupation < 40%) : Augmentation de fréquence de 5 minutes (maximum 30 min)

Optimal (taux entre 40% et 80%) : Maintien de la fréquence actuelle

Retour :
Array de tuples contenant pour chaque ligne :

ligne_id : identifiant de la ligne

nom_ligne : nom de la ligne

frequence_actuelle : fréquence actuelle en minutes

frequence_recommandee : fréquence recommandée en minutes

taux_occupation_moyen : taux d'occupation moyen calculé

gain_efficacite : gain relatif en efficacité

raison : justification textuelle de la recommandation

Exemple d'utilisation :


recommendations = Optimisation.optimiser_frequences(df_freq, df_lignes)
calculer_temps_attente(frequence_min::Int)
Description :
Calcule le temps d'attente moyen pour les usagers d'une ligne de bus.

Paramètre :

frequence_min : fréquence de passage des bus en minutes

Principe de calcul :
Le temps d'attente moyen est estimé à la moitié de l'intervalle entre les bus (modèle uniforme).

Retour :
Temps d'attente moyen en minutes (valeur flottante)

Formule :
temps_attente = frequence_min / 2.0

Exemple :


temps_attente = calculer_temps_attente(10)  # Retourne 5.0
evaluer_impact_optimisation(recommandations, df_lignes_original::DataFrame)
Description :
Évalue l'impact global des recommandations d'optimisation sur les temps d'attente des usagers.

Paramètres :

recommandations : résultat de la fonction optimiser_frequences

df_lignes_original : DataFrame des lignes avant optimisation

Métrique calculée :
Différence cumulée des temps d'attente avant et après optimisation.

Retour :
Tuple contenant :

impact_total : réduction totale du temps d'attente en minutes

lignes_optimisees : nombre de lignes ayant reçu une recommandation de changement

Exemple d'utilisation :


impact = evaluer_impact_optimisation(recommandations, df_lignes)
println("Réduction totale du temps d'attente : $(impact.impact_total) minutes")
Dépendances
Le module nécessite les packages suivants :

DataFrames : manipulation des données tabulaires

Statistics : calculs statistiques de base

Printf : formatage des chaînes de caractères

Structure des données d'entrée
DataFrame de fréquentation requis :

df_frequentation = DataFrame(
    ligne_id = [1, 1, 2, 2],
    occupation_bus = [45, 50, 20, 25],
    capacite_bus = [60, 60, 50, 50]
)
DataFrame des lignes requis :
julia
df_lignes = DataFrame(
    id = [1, 2],
    nom_ligne = ["Ligne A", "Ligne B"],
    frequence_min = [10, 15]
)

"""

# optimisation.jl - Algorithmes d'optimisation
module Optimisation
using DataFrames, Statistics, Printf

export optimiser_frequences, calculer_temps_attente, evaluer_impact_optimisation

function optimiser_frequences(df_frequentation::DataFrame, df_lignes::DataFrame)
    recommendations = []
    
    # Calcul du taux d'occupation moyen par ligne
    occupation_par_ligne = combine(
        groupby(df_frequentation, :ligne_id),
        :occupation_bus => mean => :occupation_moyenne,
        :capacite_bus => mean => :capacite_moyenne
    )
    
    occupation_par_ligne.taux_occupation = occupation_par_ligne.occupation_moyenne ./ occupation_par_ligne.capacite_moyenne
    
    for ligne in eachrow(df_lignes)
        ligne_id = ligne.id
        occupation_data = filter(r -> r.ligne_id == ligne_id, occupation_par_ligne)
        
        if nrow(occupation_data) > 0
            taux_occupation = occupation_data.taux_occupation[1]
            frequence_actuelle = ligne.frequence_min
            
            if taux_occupation > 0.8
                # Ligne surchargée - réduire la fréquence
                nouvelle_freq = max(5, frequence_actuelle - 5)
                raison = "Surcharge (occupation: $(@sprintf("%.1f%%", taux_occupation*100)))"
            elseif taux_occupation < 0.4
                # Ligne sous-utilisée - augmenter la fréquence
                nouvelle_freq = min(30, frequence_actuelle + 5)
                raison = "Sous-utilisation (occupation: $(@sprintf("%.1f%%", taux_occupation*100)))"
            else
                # Fréquence optimale
                nouvelle_freq = frequence_actuelle
                raison = "Optimal (occupation: $(@sprintf("%.1f%%", taux_occupation*100)))"
            end
            
            gain = abs(frequence_actuelle - nouvelle_freq) / frequence_actuelle
            
            push!(recommendations, (
                ligne_id = ligne_id,
                nom_ligne = ligne.nom_ligne,
                frequence_actuelle = frequence_actuelle,
                frequence_recommandee = nouvelle_freq,
                taux_occupation_moyen = taux_occupation,
                gain_efficacite = gain,
                raison = raison
            ))
        end
    end
    
    return recommendations
end

function calculer_temps_attente(frequence_min::Int)
    # Temps d'attente moyen = moitié de l'intervalle entre les bus
    return frequence_min / 2.0
end

function evaluer_impact_optimisation(recommandations, df_lignes_original::DataFrame)
    impact_total = 0.0
    lignes_optimisees = 0
    
    for rec in recommandations
        if rec.frequence_actuelle != rec.frequence_recommandee
            temps_attente_avant = calculer_temps_attente(rec.frequence_actuelle)
            temps_attente_apres = calculer_temps_attente(rec.frequence_recommandee)
            impact = temps_attente_avant - temps_attente_apres
            impact_total += impact
            lignes_optimisees += 1
        end
    end
    
    return (impact_total = impact_total, lignes_optimisees = lignes_optimisees)
end

end