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