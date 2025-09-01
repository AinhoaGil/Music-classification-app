% 1. Definir la ruta de la carpeta de géneros
baseDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Dataset\genres';

% 2. Definir los géneros
genres = {'afrobeats','blues', 'classical', 'country', 'dance','disco', 'hiphop', 'jazz', 'loFi_HipHop', 'metal', 'pop', 'reggae', 'reggaeton', 'rock', 'techHouse'};


% Inicializar variables para almacenar características y etiquetas
data = [];       % Para almacenar las características MFCC
labels = {};     % Para almacenar las etiquetas (emociones)

% Extensiones de audio a buscar
extensions = {'*.au', '*.wav', '*.mp3'};

% 3. Iterar sobre cada género
for i = 1:length(genres)
    % Obtener la ruta del género
    genreDir = fullfile(baseDir, genres{i});

    % Inicializar arreglo para almacenar todos los archivos de audio en la carpeta
    files = [];
    
    %Para cada extensión, se utiliza dir(fullfile(genreDir, extensions{j})) 
    % para obtener la lista de archivos en la carpeta genreDir que coinciden con esa extensión.
    for j = 1:length(extensions)
        files = [files; dir(fullfile(genreDir, extensions{j}))];
    end


    if ~isempty(files)
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
    
            % EXTRAER LOS MFCC
            coeffs = mfcc(audioData, fs, 'NumCoeffs', 13, 'WindowLength', round(0.025*fs), 'OverlapLength', round(0.015*fs));
            coeffs = coeffs(:, 2:end); % Excluir el primer coeficiente MFCC
            mfccFeatures = mean(coeffs, 1); % Promediar los coeficientes a lo largo del tiempo
    
             % Guardar las características y la etiqueta
            data = [data;  mfccFeatures]; % Guardar solo el promedio para cada archivo
            labels = [labels; genres{i}]; % Añadir la etiqueta correspondiente
    
    %         soundsc(audioData, fs); % Reproduce la canción

    %       -----------REPRESENTACION GRAFICA------------
    %         % Crear una nueva figura para cada género
    %         figure('Name', ['Genre - ', genres{i}], 'Position', get(0, 'ScreenSize'));
    
            % Definir el tiempo
    %         T = 1/fs;
    %         t = 0:T:(length(audioData)*T) - T;
    
            % Graficar la amplitud en el tiempo
    %         subplot(2, 1, 1);
    %         plot(t, audioData);
    %         axis tight;
    %         xlabel('Tiempo (s)');
    %         ylabel('Amplitud');
    %         title(['Género: ', genres{i}]);
    %         grid on;

    %         subplot(2, 1, 2);
    %         imagesc(coeffs'); % Graficar los coeficientes MFCC
    %         axis tight;
    %         xlabel('Tiempo (frames)');
    %         ylabel('Coeficientes MFCC');
    %         title('MFCC');
    %         colorbar;
    %         grid on;
    
            % Pausar para esperar que termine la canción
    %         pause(length(audioData) / fs); % Pausa según la duración del audio
        end
    else
        disp(['No se encontraron archivos .au en la carpeta de ', genres{i}]);
    end
end
%% 
% 5. Crear una tabla con las características y las etiquetas
mfccTable = array2table(data, 'VariableNames', ...
    {'MFCC_2', 'MFCC_3', 'MFCC_4', 'MFCC_5', 'MFCC_6', 'MFCC_7', ...
     'MFCC_8', 'MFCC_9', 'MFCC_10', 'MFCC_11', 'MFCC_12', 'MFCC_13', 'MFCC_14'});
mfccTable.Genres = labels;

% 6. Guardar la tabla para usarla en clasificadores
disp('Características extraídas y almacenadas.');
%% 

% Definir la ruta completa al directorio
FeaturesDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Features\FeaturesExtration\Genres\Datatables';

% Guardar el archivo .mat en el directorio especificado
save(fullfile(FeaturesDir, 'mfccTableGenres.mat'), 'mfccTable');
