% 1. Definir la ruta de la carpeta de géneros
baseDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Dataset\genres';

% 2. Definir los géneros
genres = {'afrobeats','blues', 'classical', 'country', 'dance','disco', 'hiphop', 'jazz', 'loFi_HipHop', 'metal', 'pop', 'reggae', 'reggaeton', 'rock', 'techHouse'};

% Inicializar variables para almacenar características y etiquetas
data = [];       % Para almacenar los valores del pitch
labels = {};     % Para almacenar las etiquetas (géneros)

% Extensiones de audio a buscar
extensions = {'*.au', '*.wav', '*.mp3'};

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

            centroidVals = spectralCentroid(audioData, fs);

            %Obtenemos en total 2992 coeffs, para simplificarlos calculamos varias estadísticas 
            % (promedio, desviación estándar, mínimo y máximo) para representar mejor la variabilidad 
            % y la distribución de esta característica a lo largo del tiempo. 
            % Esto permite capturar más detalles sobre cómo cambia el contenido espectral del audio, 
            % lo que puede mejorar el rendimiento de los clasificadores al proporcionar información 
            % más rica.
            centroidMean = mean(centroidVals);
            centroidStd = std(centroidVals);
            centroidMin = min(centroidVals);
            centroidMax = max(centroidVals);

            % Guardar las características y la etiqueta
            featureMeans = [centroidMean, centroidStd, centroidMin, centroidMax]; % Guardar las características estadísticas

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
%             % Graficar Spectral Centroides **CAMBIAR*
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
featureNames = {'centroidMean', 'centroidStd', 'centroidMin', 'centroidMax'};
specCTable = array2table(data, 'VariableNames', featureNames);
specCTable.Genre = labels;

%%
% 6. Guardar la tabla para usarla en clasificadores
% Guardar el archivo .mat en el directorio especificado
FeaturesDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Features\FeaturesExtration\Genres\Datatables';
save(fullfile(FeaturesDir, 'specCTableGenres.mat'), 'specCTable');

disp('Características MelSpectrogram extraídas y almacenadas.');

