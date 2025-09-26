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