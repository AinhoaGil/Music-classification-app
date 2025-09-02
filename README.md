# Automatic Music Genre & Emotion Classification App

## Estructura de Archivos


│
├── MusicClassificator.exe  
│   └── Ejecutable de la aplicación  
│
├── Models/  (única carpeta necesaria para la ejecución de la aplicación) 
│   ├── Genre/  
│   │   ├── HR/  
│   │   │   ├── model_KNN/NN/SVM.mat: modelo de clasificación generado con la app Classification Learner  
│   │   │   ├── CM_genre_KNN/NN/SVM.png: imagen de la matriz de confusión de cada modelo para ese conjunto de características  
│   │   │   ├── data_KNN.mat: vector con la característica extraída  
│   │   │   └── ClassLearner_XX.mat: archivo que guarda la sesión de Classification Learner utilizada para la generación de los modelos  
│   │   ├── HR_MFCC/  
│   │   │   └── … (idéntico al anterior)  
│   │   └── … (resto de combinaciones)  
│   └── Emotion/  
│       └── … (estructura idéntica a Genre)  
│
├── Dataset/  (no necesaria para la ejecución de la aplicación y no incluida en el repositorio por tamaño, ver enlaces abajo) 
│   ├── Genres/  
│   │   ├── afrohouse.00001.mp3  
│   │   └── … (audios .mp3/.au/.wav renombrados)  
│   └── Osfstorage-emotions/  
│       ├── 001.mp3  
│       └── … (soundtracks usados junto con mean_ratings_set2.csv)  
│   └── mean_ratings_set2.csv           # CSV con etiquetas de emociones  
│
├── FeaturesExtraction/  (no necesaria para la ejecución de la aplicación) 
│   ├── Genres/  
│   │   ├── Datatables/  
│   │   │   └── Archivos .mat con los vectores de características extraídas  
│   │   ├── HarmonicRatioGenres.mat  
│   │   └── … (scripts .mat utilizados para la extracción de cada característica)  
│   └── Emotions/  
│   │   ├── Datatables/  
│   │   │   └── Archivos .mat con los vectores de características extraídas  
│   │   ├── HarmonicRatioEmotions.mat  
│   │   └── … (scripts .mat utilizados para la extracción de cada característica)  
│
└── README.md                           # Este archivo  

---

## Requisitos Previos

- **MATLAB R2022b Update 10** (o superior)
---

## Datasets

Los datasets utilizados en este proyecto **no se incluyen en este repositorio debido a su tamaño**.  
Pueden descargarse desde las siguientes fuentes oficiales:

- **Géneros musicales (GTZAN Dataset):**  
  [https://www.kaggle.com/datasets/andradaolteanu/gtzan-dataset-music-genre-classification/data](https://www.kaggle.com/datasets/andradaolteanu/gtzan-dataset-music-genre-classification/data)

- **Emociones musicales (Soundtracks Dataset):**  
  [https://osf.io/p6vkg/](https://osf.io/p6vkg/)

> Una vez descargados, deben colocarse en la carpeta `Dataset/` siguiendo la estructura descrita en este README.

## Uso de la App

1. Descargar los modelos incluidos en este repositorio (carpeta `Models`).  
2. Descargar los datasets originales desde:  
   - Géneros: [GTZAN Dataset en Kaggle](https://www.kaggle.com/datasets/andradaolteanu/gtzan-dataset-music-genre-classification/data)  
   - Emociones: [OSF Dataset](https://osf.io/p6vkg/)  
3. Ejecutar la aplicación:  
   - Opción A: Abrir el archivo `MusicClassificator.mlapp` en MATLAB App Designer.  
   - Opción B: Usar el ejecutable compilado.  

⚠️ **Ejecutable (`MusicClassificator.exe`)**  
Por limitaciones de tamaño en GitHub, el archivo compilado no se incluye en este repositorio.  
Puede descargarse aquí: [https://drive.google.com/file/d/1AziCCZCq7Cw0nhpuppAvoJL1ew4-isTC/view?usp=sharing]  

4. En la aplicación:  
   - Cargar un archivo de audio con el botón *Load*.  
   - Reproducirlo con *Play* (pausable).  
   - Seleccionar las características deseadas, visualizar su representación y descripción.  
   - Elegir tipo de predicción, características y modelo.  
   - Cargar el modelo → visualizar la matriz de confusión y métricas.  
   - Predecir el género o la emoción de nuevas muestras de audio.  


---

## Referencias
- MathWorks Audio Toolbox Documentation: [https://www.mathworks.com/products/audio.html](https://www.mathworks.com/products/audio.html)
- MathWorks Classification Learner App: [https://www.mathworks.com/help/stats/classificationlearner-app.html](https://www.mathworks.com/help/stats/classificationlearner-app.html)

---


