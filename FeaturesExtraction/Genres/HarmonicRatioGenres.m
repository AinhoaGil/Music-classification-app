% https://es.mathworks.com/help/audio/ref/harmonicratio.html
% 1. Definir la ruta de la carpeta de géneros
baseDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Dataset\genres';

% 2. Definir los géneros
genres = {'afrobeats','blues', 'classical', 'country', 'dance','disco', 'hiphop', 'jazz', 'loFi_HipHop', 'metal', 'pop', 'reggae', 'reggaeton', 'rock', 'techHouse'};

% Inicializar variables para almacenar características y etiquetas
data = [];       % Para almacenar los valores del pitch
labels = {};     % Para almacenar las etiquetas (géneros)

% Extensiones de audio a buscar
extensions = {'*.au', '*.wav', '*.mp3'};

%    hFig  =  figure('Name', ['Género - ', genres{i}], 'Position', get(0, 'ScreenSize'));
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

            % EXTRAER EL Harmonic Ratio
            hrValues = harmonicRatio(audioData,fs, ...
                   Window=hann(round(fs.*0.05),"periodic"), ...  % Ventana de 50 ms
                   OverlapLength=round(fs.*0.025));  % Superposición del 90%

            % Calcular el valor promedio, la desviación estándar, el valor máximo y el valor mínimo del HR
            HRmean = mean(hrValues);  % Promedio
            HRstd = std(hrValues);    % Desviación estándar
            HRmax = max(hrValues);    % Valor máximo
            HRmin = min(hrValues);    % Valor mínimo

             % Guardar las características y la etiqueta
            featureMeans = [HRmean, HRstd, HRmax, HRmin]; % Guardar las características estadísticas

            % Almacenar todas las características
            data = [data; featureMeans];  % Guardar todas las características
            labels = [labels; genres{i}]; % Añadir la etiqueta correspondiente

%            -----------REPRESENTACION GRAFICA------------
            % Crear figura para graficar
%             figure('Name', ['Género - ', genres{i}], 'Position', get(0, 'ScreenSize'));

            % Definir el tiempo para el gráfico
            T = 1/fs;
            t = 0:T:(length(audioData)*T) - T;
               
%            clf(hFig); % Limpiar la figura antes de cada nuevo plot
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
%             % Graficar los valores del HR
%             subplot(2, 1, 2);
             plot(hrValues);
             xlabel('Tiempo (s)');
             ylabel('Harmonic Ratio');
             title('Harmonic Ratio');
             grid on;

 % Pausar un poco para que se actualicen las gráficas
%     pause(0.5); % Ajusta el tiempo de pausa según lo que necesites

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
featureNames = {'HRmean', 'HRstd', 'HRmax', 'HRmin'};
HRTable = array2table(data, 'VariableNames', featureNames);
HRTable.Genre = labels;

%%
% 6. Guardar la tabla para usarla en clasificadores
% Definir la ruta completa al directorio
FeaturesDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Features\FeaturesExtration\Genres\Datatables';
% Guardar el archivo .mat en el directorio especificado
save(fullfile(FeaturesDir, 'HRTableGenres.mat'), 'HRTable');

disp('Características extraídas y almacenadas.')

%% COMPARACIÓN DE DOS HR
% Rutas completas de los archivos de audio
fileClassical = 'genres\classical\classical.00030.au';
fileRock = 'genres\metal\metal.00030.au';

% Cargar y procesar archivo de música clásica
[audioC, fsC] = audioread(fileClassical);
if size(audioC, 2) > 1
    audioC = mean(audioC, 2); % Convertir a mono si es estéreo
end
hrC = harmonicRatio(audioC, fsC, ...
    Window=hann(round(fsC * 0.05), "periodic"), ...
    OverlapLength=round(fsC * 0.025));

% Cargar y procesar archivo de rock
[audioR, fsR] = audioread(fileRock);
if size(audioR, 2) > 1
    audioR = mean(audioR, 2); % Convertir a mono si es estéreo
end
hrR = harmonicRatio(audioR, fsR, ...
    Window=hann(round(fsR * 0.05), "periodic"), ...
    OverlapLength=round(fsR * 0.025));

% Igualar longitud para graficar
minLength = min(length(hrC), length(hrR));
hrC = hrC(1:minLength);
hrR = hrR(1:minLength);

% Representación superpuesta
figure('Name', 'Harmonic Ratio - Classical vs Metal');
plot(hrC, 'b', 'DisplayName', 'Classical');
hold on;
plot(hrR, 'r', 'DisplayName', 'Metal');
hold off;
xlabel('Frames');
ylabel('Harmonic Ratio');
legend('Location', 'best');
grid on;
ylim([0 1]);

