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