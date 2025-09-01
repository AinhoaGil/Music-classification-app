% 1. Definir la ruta de la carpeta de audio y el CSV
baseDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\AudioToolbox\Dataset\Osfstorage-emotions'; % Ruta de los audios
csvFile = fullfile(baseDir, 'mean_ratings_set2.csv'); % Ruta del CSV
audioDir = fullfile(baseDir, 'Set2', 'set2');

% 2. Leer el archivo CSV
dataTable = readtable(csvFile);

% 3. Inicializar variables para almacenar características y etiquetas
data = [];       % Para almacenar las características MFCC
labels = {};     % Para almacenar las etiquetas (emociones)

% 4. Procesar cada archivo de audio
for i = 1:height(dataTable)
    % Obtener el nombre del archivo y la etiqueta
    fileName = sprintf('%03d.mp3', dataTable.Number(i)); % Nombre como 001.mp3, 002.mp3, etc.
    fileNameCompleted = dataTable.soundtrack{i}; % Nombre del archivo de audio
    emotion = dataTable.TARGET{i}; % Emoción correspondiente

    filePath = fullfile(audioDir, fileName); % Ruta completa al archivo
    
    if isfile(filePath)
        % Leer el archivo de audio
        [audioData, fs] = audioread(filePath);
        disp(['Procesando archivo: ', fileName, ' - Emoción: ', emotion]);

        %Reproducir el archivo de audio
%         soundsc(audioData, fs); % Reproduce el audio

        % Convertir a mono
        audioData = mean(audioData, 2);
        
        %GRAFICAR
%          % Crear figura para graficar
%         figure('Name', ['Audio - ', fileNameCompleted, ' | Emoción: ', emotion], ...
%             'Position', get(0, 'ScreenSize'));
% 
%         % Definir el tiempo para el gráfico
%         T = 1/fs;
%         t = 0:T:(length(audioData)*T) - T;
%         
%         % Graficar la señal de audio en el tiempo
%         subplot(2, 1, 1);
%         plot(t, audioData);
%         axis tight;
%         xlabel('Tiempo (s)');
%         ylabel('Amplitud');
%         title(['Audio: ', fileNameCompleted, ' | Emoción: ', emotion]);
%        grid on;

        % EXTRAER LOS MFCC
        coeffs = mfcc(audioData, fs, 'NumCoeffs', 13, 'WindowLength', round(0.025*fs), 'OverlapLength', round(0.015*fs));
        coeffs = coeffs(:, 2:end); % Excluir el primer coeficiente MFCC
        mfccFeatures = mean(coeffs, 1); % Promediar los coeficientes a lo largo del tiempo
%         subplot(2, 1, 2);
%         imagesc(coeffs'); % Graficar los coeficientes MFCC
%         axis tight;
%         xlabel('Tiempo (frames)');
%         ylabel('Coeficientes MFCC');
%         title('MFCC');
%         colorbar;
%         grid on;

        % Guardar las características y la etiqueta
        data = [data;  mfccFeatures]; % Guardar solo el promedio para cada archivo
        labels = [labels; dataTable.TARGET{i}]; % Añadir la etiqueta correspondiente


         % Pausar para visualizar los gráficos y permitir la reproducción
%         pause(length(audioData) / fs + 2); % Pausa para la duración del audio + 2 segundos adicionales

    else
        disp(['Archivo no encontrado: ', fileName]);
    end
end
%% 

% 5. Crear una tabla con las características y las etiquetas
mfccTable = array2table(data, 'VariableNames', ...
    {'MFCC_2', 'MFCC_3', 'MFCC_4', 'MFCC_5', 'MFCC_6', 'MFCC_7', ...
     'MFCC_8', 'MFCC_9', 'MFCC_10', 'MFCC_11', 'MFCC_12', 'MFCC_13', 'MFCC_14'});
mfccTable.Emotion = labels;

% 6. Guardar la tabla para usarla en clasificadores
disp('Características MFCC extraídas y almacenadas.');

%% 

% Definir la ruta completa al directorio
targetDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\AudioToolbox\Features\FeaturesExtration\Emotions'; 

% Guardar el archivo .mat en el directorio especificado
save(fullfile(targetDir, 'mfccTableEmotions.mat'), 'mfccTable');
