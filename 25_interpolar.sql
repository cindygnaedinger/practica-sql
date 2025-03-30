¿Qué significa "interpolar"? 
Interpolar es como "adivinar un valor intermedio" entre dos puntos conocidos. Imagínalo como dibujar una línea recta entre dos puntos en un gráfico y estimar dónde caería un valor que no está en tus datos.

📌 Ejemplo Práctico en un Call Center
Tabla de datos: Duración de llamadas (en segundos) ordenadas de menor a mayor:

Llamada	Duración (seg)
1	100
2	200
3	300
Caso 1: Percentil 50 (Mediana) SIN interpolar (PERCENTILE_DISC)
Método: Toma el valor real más cercano.

Resultado: 200 (el valor que está justo en el medio).

Caso 2: Percentil 50 CON interpolar (PERCENTILE_CONT)
Método: Como el percentil 50 cae exactamente entre 200 y 300, interpola:

Copy
Valor interpolado = 200 + (300 - 200) * 0.5 = 250  
Resultado: 250 (un valor que no existe en los datos originales, pero es el punto medio exacto).

🔍 ¿Por qué usar interpolación?
Precisión: Te da un valor más "justo" para percentiles que no coinciden con un dato exacto.

Suaviza resultados: Útil cuando tus datos son continuos (ej: tiempo, dinero).

❌ Cuando NO interpolar
Usa PERCENTILE_DISC si trabajas con:

Datos discretos (ej: número de llamadas: 1, 2, 3... no hay 2.5 llamadas).

Ratings enteros (CSAT de 1-5: no existe un 4.3).

📊 Visualización
Copy
Duración de llamadas: 100 -----200-----300  
                          ↑       ↑  
                    P50 (DISC)  P50 (CONT)  
                        200      250  
🏆 Ejemplo SQL en BigQuery
sql
Copy
-- Con interpolación (CONT)
SELECT PERCENTILE_CONT(duration_sec, 0.5) OVER() AS mediana_interpolada
FROM calls;

-- Sin interpolación (DISC)
SELECT PERCENTILE_DISC(duration_sec, 0.5) OVER() AS mediana_real
FROM calls;
Resultados:

Si tus datos son [100, 200, 300]:

CONT devuelve 250.

DISC devuelve 200.

✅ Resumen
Interpolar = Calcular un valor intermedio que no existe en tus datos.

PERCENTILE_CONT: Interpola (para métricas continuas como tiempo).

PERCENTILE_DISC: No interpola (para datos enteros o categóricos).