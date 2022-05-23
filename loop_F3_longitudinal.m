function loop_F3_longitudinal(datadir, outputdir, num_subjects, num_trials, iterations)

if ~exist('datadir','var')
    datadir = 'C:\path_to_data_dir\';
end

if ~exist('outputdir','var')
    outputdir = 'C:\path_to_output_dir\';
end

if ~exist('num_subjects','var')
    num_subjects = 2;
end

if ~exist('num_trials','var')
    num_trials = 150;
end


if ~exist('iterations','var')
    iterations = 100;
end

datafile = [datadir, 'datatable.mat'];
load(datafile)

find_bad = find(strcmp(F3_table.subject,'S4'));
F3_table(find_bad,:) = [];

F3_subjects = F3_table.subject;
F3_session = F3_table.session;
for i = 1:length(F3_subjects)
    F3splitsubs{i} = strsplit(F3_subjects{i},'S');
    F3allsubs(i) = cell2mat(F3splitsubs{i}(2));
    F3splitsession{i} = strsplit(F3_session{i},'V');
    F3allsessions(i) = cell2mat(F3splitsession{i}(2));
end

clear i

F3allsubs = str2num(F3allsubs');
F3allsessions = str2num(F3allsessions');
unique_subs = unique(F3allsubs);
unique_sessions = unique(F3allsessions);
num_sessions = length(unique_sessions);

F3_trials = F3_table.trial;
unique_F3_trials = unique(F3_trials);


%%


for i = 1:iterations
    print_string = ['outer loop number ', num2str(i)];
    disp(print_string)
    random_subjects(:,i) = randsample(unique_subs,num_subjects);
    for j = 1:num_subjects
        findsub{j,i} = find(F3allsubs == random_subjects(j,i));
        for q = 1:num_sessions
            session(q,j,i) = q;
            findsession{q,j,i} = find(F3allsessions == session(q,j,i));
            random_trials(:,q,j,i) = randsample(1:150,num_trials);
            for k = 1:num_trials
                findtrials{k,q,j,i} = find(F3_trials == random_trials(k,q,j,i));
                intersect_trial_session{k,q,j,i} = intersect(findtrials{k,q,j,i},findsession{q,j,i});
                intersect_trial_sub{k,q,j,i} = intersect(findtrials{k,q,j,i},findsub{j,i});
                find_match{k,q,j,i} = intersect(intersect_trial_sub{k,q,j,i},intersect_trial_session{k,q,j,i});
                random_TEP(k,q,j,i) = F3_table.peaktopeak(find_match{k,q,j,i});
                check_trial(k,q,j,i) = F3_trials(find_match{k,q,j,i});
                check_session(k,q,j,i) = F3allsessions(find_match{k,q,j,i});
                check_sub(k,q,j,i) = F3allsubs(find_match{k,q,j,i});
            end
            average_within_session(q,j,i) = mean(random_TEP(:,q,j,i));
            sub_by_session(q,j,i) = check_sub(1, q,j,i);
            
        end
    end
end
                
                    

clear i
clear j
clear k
clear q


%%

[dim1 dim2 dim3] = size(average_within_session);

vec_length = dim1*dim2*dim3;

index_1 = 1:num_sessions:vec_length;
index_2 = num_sessions:num_sessions:vec_length;


clear i
clear j
clear k
         
%now reshape the files so they can write to a spreadsheet
reshape_TEP_within = reshape(average_within_session, [vec_length,1]);
reshape_sub_within = reshape(sub_by_session, [vec_length, 1]);
reshape_session_within = reshape(session, [vec_length, 1]);
newtable = table(reshape_sub_within,reshape_session_within,reshape_TEP_within,'VariableNames',{'subjectID','session','TEP'});



within_results_dir = [outputdir, 'F3_longitudinal\'];
mkdir(within_results_dir)


iterations_string = num2str(iterations);
trials_string = num2str(num_trials);
if num_trials < 100
    trials_string = ['0', trials_string];
end
subjects_string = num2str(num_subjects);
% if num_subjects < 10
%     subjects_string = ['0', subjects_string];
% end
if num_subjects < 10
    subjects_string = ['0', subjects_string];
end


F3_longitudinal_filename = [within_results_dir, subjects_string, '_subjects_', ...
    trials_string, '_trials_', 'F3_', iterations_string, ...
    '_iterations_longitudinal.csv'];

writetable(newtable, F3_longitudinal_filename);