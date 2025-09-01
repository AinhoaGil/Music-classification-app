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

            % EXTRAER EL PITCH
            [pitchVals, locs] = pitch(audioData, fs, ...
                'Method', 'SRH', ...                     % Método SRH para mayor precisión en música
                'WindowLength', round(0.05 * fs), ...   % Ventana de 50 ms
                'OverlapLength', round(0.045 * fs));    % Superposición del 90%

            % Calcular el valor promedio del pitch
            pitchMean = mean(pitchVals);

            % Guardar las características y la etiqueta
            data = [data; pitchMean]; % Guardar el valor promedio del pitch
            labels = [labels; genres{i}]; % Añadir la etiqueta correspondiente

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
% 5. Crear una tabla con las características y las etiquetas
pitchTable = array2table(data, 'VariableNames', {'PitchMean'});
pitchTable.Genres = labels;

%%
% 6. Guardar la tabla para usarla en clasificadores
disp('Características extraídas y almacenadas.');

FeaturesDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Features\FeaturesExtration\Genres\Datatables';
% Guardar el archivo .mat en el directorio especificado
save(fullfile(FeaturesDir, 'pitchTableGenres.mat'), 'pitchTable');

%% COMPARACIÓN DE DOS PITCH
