% 1. Definir la ruta de la carpeta de géneros
baseDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Dataset\genres';

% 2. Definir los géneros
genres = {'afrobeats','blues', 'classical', 'country', 'dance','disco', 'hiphop', 'jazz', 'loFi_HipHop', 'metal', 'pop', 'reggae', 'reggaeton', 'rock', 'techHouse'};

% Inicializar variables para almacenar características y etiquetas
data = [];       % Para almacenar los valores del pitch
labels = {};     % Para almacenar las etiquetas (géneros)

% Extensiones de audio a buscar
extensions = {'*.au', '*.wav', '*.mp3'};

% Definir índices de las bandas seleccionadas
numCoeffs = 14; % Número de coeficientes seleccionados
selectedBands = round(linspace(1, 64, numCoeffs)); % Índices uniformemente distribuidos entre las bandas

% 3. Iterar sobre cada género
for i = 1:length(genres)
    % Iniciar el temporizador para este género
    tic;
    
    % Obtener la ruta del género
    genreDir = fullfile(baseDir, genres{i});
    
    % Inicializar arreglo para almacenar todos los archivos de audio en la carpeta
    files = [];
    
    %Para cada extensión, se utiliza dir(fullfile(genreDir, extensions{j})) 
    % para obtener la lista de archivos en la carpeta genreDir que coinciden con esa extensión.
    for j = 1:length(extensions)
        files = [files; dir(fullfile(genreDir, extensions{j}))];
    end

    if ~ isempty(files)
    % Procesar cada archivo del género
        for k = 1:length(files)

            % Cargar las canciones de cada género 
            disp(['Procesando archivo: ', files(k).name, ' - Género: ', genres{i}]);
            oldName = files(k).name;
            fullPath = fullfile(genreDir, oldName);
            
            % Intentar leer el archivo de audio
            try
                [audioData, fs] = audioread(fullPath);
            catch ME
                fprintf('Error leyendo %s: %s\n', fullPath, ME.message);
                continue;  % Saltar este archivo si hay error
            end

            % Convertir a mono si es necesario
            if size(audioData, 2) > 1
                audioData = mean(audioData, 2);
            end

        % EXTRAER LOS Mel Spectrograms
        coeffs = melSpectrogram(audioData,fs, ...
               'Window',hann(2048,'periodic'), ...
               'OverlapLength',1024, ...
               'FFTLength',4096, ...
               'NumBands',64, ...
               'FrequencyRange',[62.5,8e3]);

        %Se extrae una matriz de coefficientes en 64 bandas de frecuencia
        %(64x605), por ello vamos a extraer coeficientes representativos del Mel Spectrogram 
        % distribuidos uniformemente entre las bandas de frecuencia

        % Seleccionar 14 coeficientes de bandas representativas
        selectedFeatures = coeffs(selectedBands, :); % Extraer las bandas seleccionadas
        featureMeans = mean(selectedFeatures, 2)';   % Promediar cada banda a lo largo del tiempo

        % Guardar las características y la etiqueta
        data = [data;  featureMeans]; % Agregar los coeficientes seleccionados al dataset
        labels = [labels; genres{i}]; % Añadir la etiqueta correspondiente (genre)


%            -----------REPRESENTACION GRAFICA------------
%             % Crear figura para graficar
%             figure('Name', ['Género - ', genres{i}], 'Position', get(0, 'ScreenSize'));
% 
%             % Definir el tiempo para el gráfico
%             T = 1/fs;
%             t = 0:T:(length(audioData)*T) - T;
%             
%             % Graficar la señal de audio en el tiempo
%             subplot(2, 1, 1);
%             plot(t, audioData);
%             axis tight;
%             xlabel('Tiempo (s)');
%             ylabel('Amplitud');
%             title(['Género: ', genres{i}]);
%             grid on;
% 
%             % Graficar los valores del pitch
%             subplot(2, 1, 2);
%             plot(locs / fs, pitchVals, '-');
%             xlabel('Tiempo (s)');
%             ylabel('Pitch (Hz)');
%             title('Estimación de Pitch');
%             ylim([min(pitchVals)-20, max(pitchVals)+20]);
%             grid on;
% 
%             % Pausar para visualizar gráficos
%             pause(length(audioData) / fs + 2); % Duración del audio + 2 segundos

        end
        elapsedTime = toc;
        % Calcular minutos y segundos
        minutes = floor(elapsedTime / 60);
        seconds = mod(elapsedTime, 60);
        
        % Mostrar el tiempo en formato "minutos y segundos"
        disp(['Tiempo de ejecución para el género "', genres{i}, '": ', ...
            num2str(minutes), ' minutos y ', num2str(seconds, '%.2f'), ' segundos']);
    else
        disp(['No se encontraron archivos .au en la carpeta de ', genres{i}]);
    end
end
%% 
% 5.  Crear una tabla con las características seleccionadas y etiquetas
melFeatureNames = arrayfun(@(x) sprintf('Mel_f%d', x), selectedBands, 'UniformOutput', false);
melTable = array2table(data, 'VariableNames', melFeatureNames);
melTable.Emotion = labels;

%%
% 6. Guardar la tabla para usarla en clasificadores
% Definir la ruta completa al directorio
FeaturesDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Features\FeaturesExtration\Genres\Datatables';

% Guardar el archivo .mat en el directorio especificado
save(fullfile(FeaturesDir, 'melTableGenres.mat'), 'melTable');

disp('Características MelSpectrogram extraídas y almacenadas.');

%% COMPARACIÓN DE DOS MEL SPECTROGRAM
% Rutas completas de los archivos de audio
file1 = 'genres\techHouse\techHouse.00008.mp3';
file2 = 'genres\blues\blues.00030.au';

% Leer y convertir a mono
[audioClassical, fs1] = audioread(file1);
[audioMetal, fs2]     = audioread(file2);
if size(audioClassical, 2) > 1, audioClassical = mean(audioClassical, 2); end
if size(audioMetal, 2) > 1, audioMetal = mean(audioMetal, 2); end

% Parámetros comunes
window      = hann(2048, 'periodic');
overlap     = 1024;
fftLength   = 4096;
numBands    = 64;
freqRange   = [62.5, 8000];

% Calcular Mel-Spectrogramas
melClassical = melSpectrogram(audioClassical, fs1, ...
    'Window', window, ...
    'OverlapLength', overlap, ...
    'FFTLength', fftLength, ...
    'NumBands', numBands, ...
    'FrequencyRange', freqRange);

melMetal = melSpectrogram(audioMetal, fs2, ...
    'Window', window, ...
    'OverlapLength', overlap, ...
    'FFTLength', fftLength, ...
    'NumBands', numBands, ...
    'FrequencyRange', freqRange);

% Representación conjunta
figure('Name','Comparativa Mel-Spectrogram: TechHouse vs. Blues');

subplot(1,2,1)
imagesc(10*log10(melClassical));
axis xy;
xlabel('Frames'); ylabel('Bandas Mel');
title('Mel-Spectrograma - TechHouse');
colorbar;

subplot(1,2,2)
imagesc(10*log10(melMetal));
axis xy;
xlabel('Frames'); ylabel('Bandas Mel');
title('Mel-Spectrograma - Blues');
colorbar;

