-- Graf 1: Top 10 hráčov podľa počtu gólov
-- Ukazuje hráčov s najvyšším počtom gólov v dataset-e (zápasy sú agregované cez fact tabuľku).
SELECT
  COALESCE(
    p.PLAYER_KNOWN_NAME,
    p.PLAYER_FIRST_NAME || ' ' || p.PLAYER_LAST_NAME,
    'Unknown'
  ) AS player_name,
  SUM(f.GOALS) AS total_goals
FROM FACT_PLAYER_MATCH f
JOIN DIM_PLAYER p ON p.PLAYER_ID = f.PLAYER_ID
GROUP BY 1
HAVING SUM(f.GOALS) > 0 -- berieme len hráčov, ktorí aspoň raz skórovali
ORDER BY total_goals DESC
LIMIT 10;

-- Graf 2: Najlepší hráči podľa presnosti prihrávok (minimálne 50 prihrávok)
-- Počítame presnosť prihrávok ako pomer ACCURATE_PASS / TOTAL_PASS, aby sme porovnali kvalitu prihrávania.
-- Filter (>= 50) eliminuje hráčov s veľmi malým počtom prihrávok, aby výsledok nebol skreslený.
SELECT
  COALESCE(
    p.PLAYER_KNOWN_NAME,
    p.PLAYER_FIRST_NAME || ' ' || p.PLAYER_LAST_NAME,
    p.PLAYER_LAST_NAME,
    p.PLAYER_FIRST_NAME,
    'Unknown'
  ) AS player_name,
  SUM(f.ACCURATE_PASS) AS accurate_passes,
  SUM(f.TOTAL_PASS) AS total_passes,
  (SUM(f.ACCURATE_PASS) / NULLIF(SUM(f.TOTAL_PASS), 0))::FLOAT AS pass_accuracy
FROM FACT_PLAYER_MATCH f
JOIN DIM_PLAYER p ON p.PLAYER_ID = f.PLAYER_ID
GROUP BY 1
HAVING SUM(f.TOTAL_PASS) >= 50
ORDER BY pass_accuracy DESC
LIMIT 10;

-- Graf 3: Najlepší hráči podľa strely na bránku
-- Zobrazuje hráčov, ktorí najčastejšie zakončujú presne (strely na bránu), a zároveň aj celkový počet striel.
SELECT
  COALESCE(
    p.PLAYER_KNOWN_NAME,
    p.PLAYER_FIRST_NAME || ' ' || p.PLAYER_LAST_NAME,
    p.PLAYER_LAST_NAME,
    p.PLAYER_FIRST_NAME,
    'Unknown'
  ) AS player_name,
  SUM(f.ONTARGET_SCORING_ATT) AS on_target_shots,
  SUM(f.TOTAL_SCORING_ATT) AS total_shots
FROM FACT_PLAYER_MATCH f
JOIN DIM_PLAYER p ON p.PLAYER_ID = f.PLAYER_ID
GROUP BY 1
HAVING SUM(f.ONTARGET_SCORING_ATT) > 0 -- len hráči s aspoň jednou strelou na bránu
ORDER BY on_target_shots DESC, total_shots DESC
LIMIT 15;

-- Graf 4: Najlepšie tímy podľa počtu gólov
-- Porovnanie tímov podľa celkového počtu gólov (agregácia cez všetkých hráčov v zápasoch).
SELECT
  t.NAME AS team_name,
  SUM(f.GOALS) AS team_goals
FROM FACT_PLAYER_MATCH f
JOIN DIM_TEAM t ON t.TEAM_ID = f.TEAM_ID
GROUP BY 1
ORDER BY team_goals DESC;

-- Graf 5: Tímy-Strely vs Góly
-- Pre každý tím počítame počet striel, gólov a striel na bránu. Vhodné na scatter (X=total_shots, Y=team_goals).
SELECT
  t.NAME AS team_name,
  SUM(f.TOTAL_SCORING_ATT) AS total_shots,
  SUM(f.GOALS) AS team_goals,
  SUM(f.ONTARGET_SCORING_ATT) AS on_target_shots
FROM FACT_PLAYER_MATCH f
JOIN DIM_TEAM t ON t.TEAM_ID = f.TEAM_ID
GROUP BY 1
ORDER BY total_shots DESC;

-- Graf 6: Najlepšie tímy podľa počtu presných prihrávok
-- Ukazuje, ktoré tímy majú najväčší objem presných prihrávok (indikátor štýlu hry / držania lopty).
SELECT
  t.NAME AS team_name,
  SUM(f.ACCURATE_PASS) AS team_accurate_passes
FROM FACT_PLAYER_MATCH f
JOIN DIM_TEAM t ON t.TEAM_ID = f.TEAM_ID
GROUP BY 1
ORDER BY team_accurate_passes DESC;

