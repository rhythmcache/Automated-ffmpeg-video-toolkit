#!/bin/bash

# https://github.com/rhythmcache
# rhythmcache.t.me
# t.me/ximistuffs

# Function to install a package
install_package() {
  local package="$1"
  
  # Detect package manager and install the package
  if command -v pkg &> /dev/null; then
    pkg update && pkg install -y "$package"
  elif command -v dnf &> /dev/null; then
    sudo dnf install -y "$package"
  elif command -v pacman &> /dev/null; then
    sudo pacman -Sy --noconfirm "$package"
  elif command -v zypper &> /dev/null; then
    sudo zypper install -y "$package"
  elif command -v yum &> /dev/null; then
    sudo yum install -y "$package"
  elif command -v apk &> /dev/null; then
    sudo apk add "$package"
  elif command -v apt &> /dev/null; then  # Termux package manager
    sudo apt update && sudo apt install -y "$package"
  else
    echo "Error: Unsupported package manager. Please install $package manually."
    exit 1
  fi
}

# Check for ffmpeg and  install
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg not found. Installing..."
    install_package "ffmpeg" || { echo "Failed to install ffmpeg."; exit 1; }
fi

# Color codes for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

#!/bin/bash

# Assuming the color variables (GREEN, CYAN, RESET) are defined above

echo -e "====================================="
echo -e "  ${CYAN}FFmpeg Automator${RESET}"
echo -e "  ${YELLOW}  by e1phn  ${RESET}"
echo -e "======================================"
sleep 1
echo -e "${CYAN}Please enter the output directory (Leave blank for current directory):${RESET}"

# Read user input into output_dir
read output_dir

# If no input is provided, set default to current directory
if [[ -z "$output_dir" ]]; then
  output_dir="."
fi

echo "Output directory is: $output_dir"

# Check if output directory exists
if [ ! -d "$output_dir" ]; then
  echo -e "${RED}Error: Output directory does not exist! Exiting...${RESET}"
  exit 1
fi

# Function to display the main menu
display_menu() {
    clear
    echo -e "=====================================     "
    echo -e "  ${GREEN}FFmpeg Automator${RESET}"
    echo -e "====================================="
    echo -e "${CYAN}1. Convert Video Format"
    echo -e "2. Compress Video"
    echo -e "3. Trim Video"
    echo -e "4. Extract Audio from Video"
    echo -e "5. Merge Videos"
    echo -e "6. Apply Video Filters (Resize, Rotate)"
    echo -e "7. Extract Video Frames/Thumbnails"
    echo -e "8. Change Video Resolution"
    echo -e "9. Add Image Watermark"
    echo -e "10. Add Text Watermark"
    echo -e "11. Create GIF from Video"
    echo -e "12. Edit Metadata"
    echo -e "13. Reverse Video/Audio"
    echo -e "14. Change Video/Audio Playback Speed"
    echo -e "15. Convert Videos into android bootanimation magisk module"
    echo -e "16. Extract embedded subtitles from a video"
    echo -e "17. Permanently add the subtitles to the video"
    echo -e "18. Apply a blur effect to the video"
    echo -e "19. Combine Separate Audio and Video"
    echo -e "20. Create Picture in Picture"
    echo -e "21. Change Video FPS"
    echo -e "22. Apply Fade Effect to the audio of the video"
    #echo -e "14. Screen Capture"
    echo -e "23. Exit${RESET}"
    echo    "=========================================="
}

# Function to get video info
bugs() {
    echo -e "${YELLOW} > > > Report Bugs at @ximistuffschat ${RESET}"
}

# Function to get video info
get_video_info() {
    ffmpeg -i "$1" 2>&1 | grep "Duration\|Stream"
}

# Function to prompt for input file
prompt_input_file() {
    echo -e "${CYAN}Enter the input video file path:${RESET}"
    read input_file

    if [ ! -f "$input_file" ]; then
        echo -e "${RED}Error: File not found! Exiting...${RESET}"
        exit 1
    fi

    # Show video properties
    echo -e "${CYAN}Video Properties:${RESET}"
    get_video_info "$input_file"
    sleep 1
}

# Video format conversion
convert_video() {
    prompt_input_file
    echo -e "${CYAN}Enter the output format (e.g., mp4, avi, mkv):${RESET}"
    read format
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.}).$format"
    ffmpeg -i "$input_file" "$output_file"
    echo -e "${GREEN}Video converted to $output_file${RESET}"
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    bugs
    read  # Pause and wait for user to press Enter
}

# Function to Extract Subtitles from a Video
extract_subtitles() {
    prompt_input_file
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_subtitles.srt"
    ffmpeg -i "$input_file" -map 0:s:0 "$output_file"
    echo -e "${GREEN}Subtitles extracted and saved to $output_file${RESET}"
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    bugs
    read  # Pause and wait for user to press Enter
}

# Video compression
compress_video() {
    prompt_input_file
    echo -e "${CYAN}Enter the compression bitrate (e.g., 500k, 1M):${RESET}"
    read bitrate
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_compressed.mp4"
    ffmpeg -i "$input_file" -b:v "$bitrate" "$output_file"
    echo -e "${GREEN}Video compressed to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}

# Function to Burn Subtitles to a Video
burn_subtitles_to_video() {
    prompt_input_file
    echo "This will permanently burn subtitles onto video"
    echo -e "${CYAN}Enter the path to the subtitle file (e.g., subtitles.srt):${RESET}"
    read subtitle_file
    if [[ ! -f "$subtitle_file" ]]; then
        echo -e "${RED}Subtitle file not found!${RESET}"
        return
    fi
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_with_subtitles.mp4"
    ffmpeg -i "$input_file" -i "$subtitle_file" -c:v libx264 -c:a copy -vf "subtitles=$subtitle_file" "$output_file"
    echo -e "${GREEN}Subtitles burned into video and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}

# Function for Blurred Background 

create_blurred_background() {
    prompt_input_file
    echo -e "${CYAN}Enter the intensity of the blur (e.g., 10:1):${RESET}"
    read blur_intensity
    echo -e "${CYAN}Enter the x and y coordinates of the focused area (e.g., 2:3):${RESET}"
    read focus_coordinates

    # Split focus_coordinates by ":" to extract x and y values
    x=$(echo $focus_coordinates | cut -d':' -f1)
    y=$(echo $focus_coordinates | cut -d':' -f2)

    # Validate the x and y coordinates (must be positive integers)
    if ! [[ "$x" =~ ^[0-9]+$ ]] || ! [[ "$y" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid coordinates. Please enter valid positive integers for x and y.${RESET}"
        return
    fi

    # Prompt the user for the width and height of the focused area
    echo -e "${CYAN}Enter the width of the focused area (e.g., 200):${RESET}"
    read width
    echo -e "${CYAN}Enter the height of the focused area (e.g., 200):${RESET}"
    read height

    # Validate width and height (must be positive integers)
    if ! [[ "$width" =~ ^[0-9]+$ ]] || ! [[ "$height" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid width or height. Please enter valid positive integers.${RESET}"
        return
    fi

    # Set output file name
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_blurred_background.mp4"

    # Run FFmpeg to apply the blur with the focused area
    ffmpeg -i "$input_file" -vf "boxblur=$blur_intensity,delogo=x=$x:y=$y:w=$width:h=$height" -c:a copy "$output_file"

    echo -e "${GREEN}Blurred background effect applied and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}


#combine separate audio and video
combine_audio_video() {
    prompt_input_file  # Main video
    echo -e "${CYAN}Enter the path to the audio file (e.g., audio.mp3):${RESET}"
    read audio_file

    # Check if the audio file exists
    if [[ ! -f "$audio_file" ]]; then
        echo -e "${RED}Audio file not found!${RESET}"
        return
    fi

    # Get the video and audio durations
    video_duration=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$input_file")
    audio_duration=$(ffprobe -v error -select_streams a:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file")

    # Set the output file name
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_combined.mp4"

    # Compare video and audio lengths
    if (( $(echo "$video_duration > $audio_duration" | bc -l) )); then
        # Video is longer than the audio
        echo -e "${CYAN}The video is longer than the audio.${RESET}"
        echo -e "${CYAN}Choose an option:${RESET}"
        echo -e "1) Dont trim video"
        echo -e "2) Trim the video to match audio length"
        read -p "Enter your choice (1 or 2): " action

        if [[ "$action" == "1" ]]; then
            # Repeat the audio to match the video length
            ffmpeg -i "$input_file" -i "$audio_file" -c:v copy -map 0:v -map 1:a -c:a aac -shortest -strict experimental "$output_file"
            echo -e "${GREEN}Audio repeated to match video length and saved to $output_file${RESET}"
        elif [[ "$action" == "2" ]]; then
            # Trim the video to match the audio length
            ffmpeg -i "$input_file" -i "$audio_file" -c:v copy -map 0:v -map 1:a -c:a aac -t "$audio_duration" -strict experimental "$output_file"
            echo -e "${GREEN} saved to $output_file${RESET}"
        else
            echo -e "${RED}Invalid option. Please choose 1 or 2.${RESET}"
        fi
    elif (( $(echo "$audio_duration > $video_duration" | bc -l) )); then
        # Audio is longer than the video
        echo -e "${CYAN}The audio is longer than the video.${RESET}"
        echo -e "${CYAN}Choose an option:${RESET}"
        echo -e "1) Trim the audio to match video length"
        echo -e "2) Continue playing the full audio after the video ends"
        read -p "Enter your choice (1 or 2): " action

        if [[ "$action" == "1" ]]; then
            # Trim the audio to match the video length
            ffmpeg -i "$input_file" -i "$audio_file" -c:v copy -map 0:v -map 1:a -c:a aac -t "$video_duration" -strict experimental "$output_file"
            echo -e "${GREEN}Audio trimmed to match video length and saved to $output_file${RESET}"
        elif [[ "$action" == "2" ]]; then
            # Allow audio to continue playing after video ends
            ffmpeg -i "$input_file" -i "$audio_file" -c:v copy -map 0:v -map 1:a -c:a aac -strict experimental "$output_file"
            echo -e "${GREEN}Audio will continue playing after video ends and saved to $output_file${RESET}"
        else
            echo -e "${RED}Invalid option. Please choose 1 or 2.${RESET}"
        fi
    else
        # Audio and video are the same length
        ffmpeg -i "$input_file" -i "$audio_file" -c:v copy -map 0:v -map 1:a -c:a aac -strict experimental "$output_file"
        echo -e "${GREEN}Audio and video have the same length. Combined and saved to $output_file${RESET}"
    fi

    # Check if the FFmpeg command was successful
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Audio and video combined and saved to $output_file${RESET}"
    else
        echo -e "${RED}Error combining audio and video.${RESET}"
    fi

    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}


# CHANGE VIDEO FPS
change_fps() {
    # Prompt for input video file
    echo -e "${CYAN}Enter input video file path:${RESET}"
    read input_file

    # Check if input file exists
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}File not found! Please check the file path.${RESET}"
        return
    fi

    # Prompt for desired FPS
    echo -e "${CYAN}Enter the desired FPS (e.g., 30, 60, etc.):${RESET}"
    read fps

    # Check if FPS is a valid number
    if ! [[ "$fps" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid FPS! Please enter a positive integer.${RESET}"
        return
    fi

    # Set output file name
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_fps${fps}.mp4"

    # Run FFmpeg command to change FPS, while keeping audio and video duration the same
    ffmpeg -i "$input_file" -filter:v "fps=$fps" -c:v libx264 -c:a aac -strict experimental "$output_file"

    # Check if FFmpeg ran successfully
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Video saved to $output_file with $fps FPS.${RESET}"
    else
        echo -e "${RED}Error changing FPS.${RESET}"
    fi
}


# Cut video based on start and end time in HH:MM:SS format
cut_video() {
    prompt_input_file

    # Ask for start and end time in HH:MM:SS format
    echo -e "${CYAN}Enter start time (in HH:MM:SS format, e.g., 00:00:25):${RESET}"
    read start_time

    echo -e "${CYAN}Enter end time (in HH:MM:SS format, e.g., 00:01:00):${RESET}"
    read end_time

    # Convert HH:MM:SS format to total seconds
    start_seconds=$(date -d "1970-01-01 $start_time UTC" +%s)
    end_seconds=$(date -d "1970-01-01 $end_time UTC" +%s)

    # Check if start time is earlier than end time
    if [ "$start_seconds" -ge "$end_seconds" ]; then
        echo -e "${RED}Error: End time must be greater than start time!${RESET}"
        return 1
    fi

    # Calculate duration in seconds
    duration=$((end_seconds - start_seconds))

    # Output file path
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_cut.mp4"

    # Run ffmpeg to cut the video
    ffmpeg -i "$input_file" -ss "$start_time" -to "$end_time" -c:v copy -c:a copy "$output_file"

    echo -e "${GREEN}Video cut from $start_time to $end_time and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Output saved at: $output_file${RESET}"
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}


# Extract audio from video
extract_audio() {
    prompt_input_file
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.}).mp3"
    ffmpeg -i "$input_file" -vn -acodec mp3 "$output_file"
    echo -e "${GREEN}Audio extracted to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}

#Merge Videos

merge_videos() {
    # Ask if videos are in the same directory or different paths
    echo -e "${CYAN}Are all videos in the same directory or different paths?${RESET}"
    echo -e "${CYAN}1. Same directory${RESET}"
    echo -e "${CYAN}2. Different paths${RESET}"
    read choice

    # Variable to store video files
    files=()

    if [ "$choice" -eq 1 ]; then
        # Same directory
        echo -e "${CYAN}Enter the directory path where the videos are located:${RESET}"
        read directory

        # Check if the directory exists and is accessible
        if [ ! -d "$directory" ]; then
            echo -e "${RED}Directory does not exist or is not accessible.${RESET}"
            return
        fi

        # List all video files in the given directory (added more formats)
        echo -e "${CYAN}Listing all video files in $directory...${RESET}"

        video_files=($(find "$directory" -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.mpg" -o -iname "*.3gp" \)))

        # Check if any video files were found
        total_videos=${#video_files[@]}
        if [ "$total_videos" -eq 0 ]; then
            echo -e "${RED}No video files found in the directory.${RESET}"
            return
        fi

        # Display the total number of videos found
        echo -e "${CYAN}Found $total_videos video(s) in the directory.${RESET}"

        # Ask if the user wants to merge all videos
        echo -e "${CYAN}Do you want to merge all the videos? (y/n):${RESET}"
        read merge_all

        if [[ "$merge_all" == "y" || "$merge_all" == "Y" ]]; then
            # User wants to merge all videos, ask for the order
            echo -e "${CYAN}Please choose the order for merging:${RESET}"
            for ((i=0; i<$total_videos; i++)); do
                echo "$((i+1)). ${video_files[$i]}"
            done

            # Ask user to choose the order of the videos
            order=()
            for ((i=0; i<$total_videos; i++)); do
                echo -e "${CYAN}Enter the number for video $((i+1)) to select from the above list (Choose in the order you want):${RESET}"
                read selected_video
                order+=("${video_files[$((selected_video-1))]}")
            done
            files=("${order[@]}")

        else
            # User does not want to merge all videos, ask which to merge
            echo -e "${CYAN}How many videos do you want to merge?${RESET}"
            read num_videos

            # Allow user to select videos
            for ((i=0; i<$num_videos; i++)); do
                echo -e "${CYAN}Enter the number for video $((i+1)) to select from the above list:${RESET}"
                read selection
                files+=("${video_files[$((selection-1))]}")
            done

            # Ask for the order
            echo -e "${CYAN}Please choose the order for merging:${RESET}"
            order=()
            for ((i=0; i<${#files[@]}; i++)); do
                echo "$((i+1)). ${files[$i]}"
            done

            # Ask user to choose the order of the selected videos
            final_order=()
            for ((i=0; i<${#files[@]}; i++)); do
                echo -e "${CYAN}Enter the number for video $((i+1)) to select from the above list (Choose in the order you want):${RESET}"
                read selected_video
                final_order+=("${files[$((selected_video-1))]}")
            done
            files=("${final_order[@]}")
        fi

    elif [ "$choice" -eq 2 ]; then
        # Different paths
        echo -e "${CYAN}How many videos do you want to merge?${RESET}"
        read num_videos

        # Get individual video file paths from the user
        for ((i=0; i<$num_videos; i++)); do
            echo -e "${CYAN}Enter the path for video $((i+1)):${RESET}"
            read video_path
            files+=("$video_path")
        done
    else
        echo -e "${RED}Invalid choice. Please choose 1 or 2.${RESET}"
        return
    fi

    # Ask the user for the resolution of the merged video
    echo -e "${CYAN}Enter the desired resolution for the merged video (e.g., 1280x720, 1920x1080):${RESET}"
    read resolution

    # Validate resolution format
    if [[ ! "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
        echo -e "${RED}Invalid resolution format. Please use WIDTHxHEIGHT (e.g., 1280x720).${RESET}"
        return
    fi

    # Create temporary directory for storing re-encoded video files
    temp_dir="./temporary"
    mkdir -p "$temp_dir"

    # Re-encode the videos to ensure they have compatible codecs, frame rates, etc.
    # This ensures that all videos are in the same format before merging
    reencoded_files=()
    for i in "${!files[@]}"; do
        # Create a temporary re-encoded file for each input video inside the temp directory
        temp_file="$temp_dir/tmp$((i+1)).mp4"
        echo -e "Creating temporary file: $temp_file"  # Debugging line
        ffmpeg -i "${files[$i]}" -c:v libx264 -c:a aac -strict experimental -r 30 -preset fast -ac 2 -ar 44100 -s "$resolution" -loglevel error "$temp_file"
        
        # Check if the temporary file exists and is valid
        if [ ! -f "$temp_file" ]; then
            echo -e "${RED}Error: Temporary file $temp_file was not created successfully.${RESET}"
            return
        fi

        reencoded_files+=("$temp_file")
    done

    # Create a temporary file to store the file list for merging
    list_file="$temp_dir/list.txt"
    > "$list_file"  # Clear the list file

    # Loop through each re-encoded video and write it to the list file
    for file in "${reencoded_files[@]}"; do
        # Write relative paths to the list file, removing './temporary/' if it exists
        echo "file '$(basename "$file")'" >> "$list_file"
    done

    # Output directory for merged video
    output_file="$output_dir/merged_video.mp4"

    # Run ffmpeg with the concat demuxer to merge the videos (muted to errors only)
    ffmpeg -f concat -safe 0 -i "$list_file" -c copy -loglevel error "$output_file"

    # Check if the merge was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Videos merged successfully and saved to $output_file${RESET}"
    else
        echo -e "${RED}An error occurred during merging.${RESET}"
        return
    fi

    # Clean up temporary directory and files
    rm -rf "$temp_dir"

    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}




# Apply video filters (resize, rotate, etc.)
apply_video_filters() {
    prompt_input_file
    echo -e "${CYAN}Enter filter to apply (e.g., resize=1280x720, rotate=90):${RESET}"
    read filter
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_filtered.mp4"
    ffmpeg -i "$input_file" -vf "$filter" "$output_file"
    echo -e "${GREEN}Filter applied and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}

#Extract video thumbnails



extract_thumbnails() {
    prompt_input_file
    echo -e "${CYAN}Would you like to extract frames from a specific duration? (y/n):${RESET}"
    read specific_duration

    if [[ "$specific_duration" == "y" || "$specific_duration" == "Y" ]]; then
        echo -e "${CYAN}Enter the start time (in seconds or HH:MM:SS format):${RESET}"
        read start_time
        echo -e "${CYAN}Enter the end time (in seconds or HH:MM:SS format):${RESET}"
        read end_time
    else
        # Default to start of the video if no specific duration is selected
        start_time=0
        end_time=$(ffmpeg -i "$input_file" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d ,)
        
        echo -e "${CYAN}Enter the number of thumbnails to extract (e.g., 5):${RESET}"
        read num_thumbnails
    fi


    # Calculate total duration in seconds for the specified range
start_seconds=$(echo "$start_time" | awk -F: '{ printf "%.0f", ($1 * 3600) + ($2 * 60) + $3 }')
end_seconds=$(echo "$end_time" | awk -F: '{ printf "%.0f", ($1 * 3600) + ($2 * 60) + $3 }')
duration=$((end_seconds - start_seconds))


    if ((duration <= 0)); then
        echo -e "${RED}Invalid duration specified. Ensure that end time is greater than start time.${RESET}"
        return 1
    fi

    if [[ "$specific_duration" == "y" || "$specific_duration" == "Y" ]]; then
        # Extract all frames within the specified duration
        ffmpeg -ss "$start_seconds" -to "$end_seconds" -i "$input_file" -vsync vfr "$output_dir/$(basename "$input_file" .${input_file##*.})_frame%04d.png"
        echo -e "${GREEN}All frames extracted from $start_time to $end_time in $output_dir${RESET}"
        bugs
        read
    else
        # Calculate interval based on the number of thumbnails and the total duration
        interval=$(echo "$duration / $num_thumbnails" | bc -l)
        
        for ((i=1; i<=num_thumbnails; i++)); do
            # Calculate the timestamp for each thumbnail
            timestamp=$(printf "%.0f" "$(echo "$start_seconds + ($interval * $i)" | bc -l)")
            output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_thumb$i.png"
            
            # Extract the frame at the calculated timestamp
            ffmpeg -ss "$timestamp" -i "$input_file" -vframes 1 "$output_file"
            
            echo -e "${GREEN}Thumbnail extracted to $output_file${RESET}"
            bugs
            echo -e "${CYAN}Press Enter to continue...${RESET}"
            read  # Pause and wait for user to press Enter
        done
    fi
}


# Change video resolution
change_resolution() {
    prompt_input_file
    echo -e "${CYAN}Enter new resolution (e.g., 1280x720):${RESET}"
    read resolution
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_${resolution}.mp4"
    ffmpeg -i "$input_file" -s "$resolution" -c:a copy "$output_file"
    echo -e "${GREEN}Resolution changed and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
    
}

# Add image watermark
add_watermark() {
    prompt_input_file
    echo -e "${CYAN}Enter watermark image file path (e.g., watermark.png):${RESET}"
    read watermark_file

    # Ask user where to place the watermark
    echo -e "${CYAN}Choose watermark position:${RESET}"
    echo -e "1. Top Left"
    echo -e "2. Top Right"
    echo -e "3. Bottom Left"
    echo -e "4. Bottom Right"
    echo -e "5. Center"
    echo -e "6. Top Center"
    echo -e "7. Bottom Center"
    echo -e "8. Custom Position"
    read position

    # Set the position for watermark
    case $position in
        1) position="10:10" ;;  # Top Left
        2) position="main_w-overlay_w-10:10" ;;  # Top Right
        3) position="10:main_h-overlay_h-10" ;;  # Bottom Left
        4) position="main_w-overlay_w-10:main_h-overlay_h-10" ;;  # Bottom Right
        5) position="main_w/2-overlay_w/2:main_h/2-overlay_h/2" ;;  # Center
        6) position="main_w/2-overlay_w/2:10" ;;  # Top Center
        7) position="main_w/2-overlay_w/2:main_h-overlay_h-10" ;;  # Bottom Center
        8) 
            echo -e "${CYAN}Enter custom x position (e.g., 50):${RESET}"
            read x_pos
            echo -e "${CYAN}Enter custom y position (e.g., 50):${RESET}"
            read y_pos
            position="$x_pos:$y_pos" ;;
        *) echo -e "${RED}Invalid choice, defaulting to top-left.${RESET}"
           position="10:10" ;;
    esac

    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_watermarked.mp4"
    ffmpeg -i "$input_file" -i "$watermark_file" -filter_complex "overlay=$position" "$output_file"
    echo -e "${GREEN}Watermark added and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}

# Add image watermark
add_watermark() {
    prompt_input_file
    echo -e "${CYAN}Enter watermark image file path (e.g., watermark.png):${RESET}"
    read watermark_file

    # Ask user where to place the watermark
    echo -e "${CYAN}Choose watermark position:${RESET}"
    echo -e "1. Top Left"
    echo -e "2. Top Right"
    echo -e "3. Bottom Left"
    echo -e "4. Bottom Right"
    echo -e "5. Center"
    echo -e "6. Top Center"
    echo -e "7. Bottom Center"
    echo -e "8. Custom Position"
    read position

    # Set the position for watermark
    case $position in
        1) position="10:10" ;;  # Top Left
        2) position="main_w-overlay_w-10:10" ;;  # Top Right
        3) position="10:main_h-overlay_h-10" ;;  # Bottom Left
        4) position="main_w-overlay_w-10:main_h-overlay_h-10" ;;  # Bottom Right
        5) position="main_w/2-overlay_w/2:main_h/2-overlay_h/2" ;;  # Center
        6) position="main_w/2-overlay_w/2:10" ;;  # Top Center
        7) position="main_w/2-overlay_w/2:main_h-overlay_h-10" ;;  # Bottom Center
        8) 
            echo -e "${CYAN}Enter custom x position (e.g., 50):${RESET}"
            read x_pos
            echo -e "${CYAN}Enter custom y position (e.g., 50):${RESET}"
            read y_pos
            position="$x_pos:$y_pos" ;;
        *) echo -e "${RED}Invalid choice, defaulting to top-left.${RESET}"
           position="10:10" ;;
    esac

    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_watermarked.mp4"

    # Resize watermark image to a smaller size (e.g., 10% of video width)
    ffmpeg -i "$input_file" -i "$watermark_file" -filter_complex "[1:v]scale=iw*0.1:-1[wm];[0:v][wm]overlay=$position" "$output_file"

    echo -e "${GREEN}Watermark added and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}


# Add text watermark

add_text_watermark() {
    prompt_input_file
    echo -e "${CYAN}Enter text for watermark:${RESET}"
    read watermark_text

    # Ask user to choose font size
    echo -e "${CYAN}Enter font size (e.g., 48):${RESET}"
    read font_size

    # Ask if the user wants to use a custom font
    echo -e "${CYAN}Do you want to use a custom font? (y/n)${RESET}"
    read use_custom_font
    if [[ "$use_custom_font" == "y" ]]; then
        echo -e "${CYAN}Enter the path to the .ttf font file:${RESET}"
        read font_path
    else
        # Default font path (update this to a valid path if needed)
        font_path="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
    fi

    # Ask user where to place the watermark
    echo -e "${CYAN}Choose watermark position:${RESET}"
    echo -e "1. Top Left"
    echo -e "2. Top Right"
    echo -e "3. Bottom Left"
    echo -e "4. Bottom Right"
    echo -e "5. Center"
    echo -e "6. Top Center"
    echo -e "7. Bottom Center"
    echo -e "8. Custom Position"
    read position

    # Set the x and y positions for the watermark
    case $position in
        1) x="10"; y="10" ;;  # Top Left
        2) x="w-tw-10"; y="10" ;;  # Top Right
        3) x="10"; y="h-th-10" ;;  # Bottom Left
        4) x="w-tw-10"; y="h-th-10" ;;  # Bottom Right
        5) x="(w-tw)/2"; y="(h-th)/2" ;;  # Center
        6) x="(w-tw)/2"; y="10" ;;  # Top Center
        7) x="(w-tw)/2"; y="h-th-10" ;;  # Bottom Center
        8) 
            echo -e "${CYAN}Enter custom x position (e.g., 50):${RESET}"
            read x
            echo -e "${CYAN}Enter custom y position (e.g., 50):${RESET}"
            read y ;;
        *) echo -e "${RED}Invalid choice, defaulting to top-left.${RESET}"
           x="10"; y="10" ;;
    esac

    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_text_watermarked.mp4"

    # Apply the drawtext filter with user-defined font size and box background for visibility
    ffmpeg -i "$input_file" -vf "drawtext=text='$watermark_text':fontfile='$font_path':fontsize=$font_size:fontcolor=white:box=1:boxcolor=black@0.5:boxborderw=5:x='$x':y='$y':shadowcolor=black:shadowx=2:shadowy=2" "$output_file"

    # Check if the output file was created successfully
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Text watermark added and saved to $output_file${RESET}"
    else
        echo -e "${RED}Failed to add watermark. Please check the font path and other inputs.${RESET}"
    fi
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    bugs
    read  
}




# Create GIF from video
create_gif() {
    prompt_input_file
    echo -e "${CYAN}Enter start time for GIF (e.g., 00:01:00 for 1 minute):${RESET}"
    read start_time
    echo -e "${CYAN}Enter duration for GIF (e.g., 10 for 10 seconds):${RESET}"
    read duration
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.}).gif"
    ffmpeg -i "$input_file" -ss "$start_time" -t "$duration" -vf "fps=10,scale=320:-1:flags=lanczos" "$output_file"
    echo -e "${GREEN}GIF created and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}

# Edit video metadata
edit_metadata() {
    prompt_input_file
    echo -e "${CYAN}Enter title for the video metadata:${RESET}"
    read title
    echo -e "${CYAN}Enter artist name for the video metadata:${RESET}"
    read artist
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_metadata.mp4"
    ffmpeg -i "$input_file" -metadata title="$title" -metadata artist="$artist" -codec copy "$output_file"
    echo -e "${GREEN}Metadata edited and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}

# Reverse video/audio
reverse_video_audio() {
    prompt_input_file
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_reversed.mp4"
    ffmpeg -i "$input_file" -filter:v reverse -filter:a areverse "$output_file"
    echo -e "${GREEN}Video and audio reversed and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}

# Function to change video speed
change_video_speed() {
    prompt_input_file
    echo -e "${CYAN}Enter the speed factor (e.g., 2.0 for double speed, 0.5 for half speed, 3.7 for 3.7x speed):${RESET}"
    read speed

    # Check for valid speed factor
    if [[ $(echo "$speed < 0.1" | bc) -eq 1 ]]; then
        echo -e "${RED}Error: Speed factor is too small. Please enter a value greater than 0.1.${RESET}"
        return 1
    fi

    # Construct output file path
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_speed_${speed}x.mp4"

    # Apply video speed change using setpts
    video_filter="setpts=PTS/$speed"

    # Prepare audio filter chain for speeds greater than 2
    audio_filters=""

    if (( $(echo "$speed <= 2.0" | bc -l) )); then
        # For speeds <= 2, use atempo filter directly
        audio_filters="atempo=$speed"
    else
        # For speeds greater than 2, apply multiple atempo filters
        while (( $(echo "$speed > 2.0" | bc -l) )); do
            audio_filters="$audio_filters,atempo=2.0"
            speed=$(echo "$speed/2" | bc -l)
        done
        # Now apply the remaining speed for audio if less than or equal to 2
        audio_filters=$(echo "$audio_filters,atempo=$speed" | sed 's/^,//')
    fi

    # Run ffmpeg to process video and audio
    ffmpeg -i "$input_file" -filter:v "$video_filter" -filter:a "$audio_filters" "$output_file"

    echo -e "${GREEN}Video speed changed and saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Output saved at: $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}

# create bootanimation.zip

convert_to_bootanimation() {
    echo -e "${CYAN}starting the bootanimation creator script...${RESET}"

    # Download the genbootanim.sh script using curl
    curl -sSL https://raw.githubusercontent.com/rhythmcache/Video-to-BootAnimation-Creator-Script/main/cbootanim.sh -o cbootanim.sh
    chmod +x cbootanim.sh
    ./cbootanim.sh
}

# Picture in Picture Mode

overlay_video() {
    prompt_input_file  # Main video
    echo -e "${CYAN}Enter overlay video file:${RESET}"
    read overlay_video

    echo -e "${CYAN}Select position for picture-in-picture overlay:${RESET}"
    echo -e "${CYAN}1) Top-left  2) Top-right  3) Bottom-left  4) Bottom-right  5) Center${RESET}"
    read position_choice

    case $position_choice in
        1)
            overlay_position="10:10"  # Top-left
            ;;
        2)
            overlay_position="W-w-10:10"  # Top-right
            ;;
        3)
            overlay_position="10:H-h-10"  # Bottom-left
            ;;
        4)
            overlay_position="W-w-10:H-h-10"  # Bottom-right
            ;;
        5)
            overlay_position="(W-w)/2:(H-h)/2"  # Center
            ;;
        *)
            echo -e "${RED}Invalid option, defaulting to top-left.${RESET}"
            overlay_position="10:10"  # Default to top-left
            ;;
    esac

    echo -e "${CYAN}Select audio option: 1 for both audio, 2 for main audio only, 3 to mute main audio:${RESET}"
    read audio_option

    # Set audio filter based on user selection
    case $audio_option in
        1)
            audio_filter="[0:a][1:a]amix=inputs=2:duration=first"
            ;;
        2)
            audio_filter="anull"  # Use only main audio without additional mixing
            ;;
        3)
            audio_filter="volume=0"  # Mute main audio
            ;;
        *)
            echo -e "${RED}Invalid option, using both audio tracks by default.${RESET}"
            audio_filter="[0:a][1:a]amix=inputs=2:duration=first"
            ;;
    esac

    # Get the resolution of the main video (input_file)
    main_video_resolution=$(ffmpeg -i "$input_file" 2>&1 | grep -oP '(?<=, )\d+x\d+' | head -n 1)
    main_video_width=$(echo $main_video_resolution | cut -d 'x' -f 1)
    main_video_height=$(echo $main_video_resolution | cut -d 'x' -f 2)

    # Calculate new overlay size (1/2 of main video size)
    overlay_width=$((main_video_width / 2))
    overlay_height=$((main_video_height / 2))

    # Set output file name
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_overlay.mp4"

    # Run FFmpeg with the correct filters
    ffmpeg -i "$input_file" -i "$overlay_video" -filter_complex \
           "[1]scale=$overlay_width:$overlay_height[ovrl];[0][ovrl]overlay=$overlay_position[vout];$audio_filter" \
           -map "[vout]" -c:v libx264 -c:a aac "$output_file"

    echo -e "${GREEN}Video saved to $output_file${RESET}"
    bugs
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read  # Pause and wait for user to press Enter
}
# Fade Effect

fade() {
    # Prompt for input video file
    prompt_input_file  # This function is assumed to prompt the user for the video file
    input_file="$input_file"  # Store selected video file path

    # Check if the input video file exists
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}Video file not found!${RESET}"
        return
    fi

    # Set duration for fade effect at start and end of audio
    fade_duration=3  # Fade effect duration in seconds
    audio_length=$(ffprobe -i "$input_file" -show_entries format=duration -v quiet -of csv="p=0")

    # Calculate fade out start time (total duration - fade duration)
    fade_out_start=$(echo "$audio_length - $fade_duration" | bc)

    # Set output file name
    output_file="${output_dir}/$(basename "$input_file" .${input_file##*.})_faded_audio.mp4"

    # Apply fade-in at the start and fade-out at the end
    ffmpeg -i "$input_file" -af "afade=t=in:ss=0:d=$fade_duration,afade=t=out:st=$fade_out_start:d=$fade_duration" -c:v copy -c:a aac "$output_file"

    # Check if the FFmpeg command was successful
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Audio fade effect applied and saved to $output_file${RESET}"
bugs
read
    else
        echo -e "${RED}Error applying fade effect to audio in video.${RESET}"
    fi
}





# Main loop
while true; do
    display_menu
    echo -e "${CYAN}Enter your choice (1-23):${RESET}"
    read choice
    case $choice in
        1) convert_video ;;
        2) compress_video ;;
        3) cut_video ;;
        4) extract_audio ;;
        5) merge_videos ;;
        6) apply_video_filters ;;
        7) extract_thumbnails ;;
        8) change_resolution ;;
        9) add_watermark ;;
        10) add_text_watermark ;;
        11) create_gif ;;
        12) edit_metadata ;;
        13) reverse_video_audio ;;
      #  14) screen_capture ;
        14) change_video_speed ;;
        15) convert_to_bootanimation ;;
        16) extract_subtitles ;;
        17) burn_subtitles_to_video ;;
        18) create_blurred_background ;;
        19) combine_audio_video ;;
        20) overlay_video ;;
        21) change_fps ;;
        22) fade ;;
        23) exit 0 ;;
        *) echo -e "${RED}Invalid option, please try again.${RESET}" ;;
    esac
done
# https://github.com/rhythmcache
# t.me/e1phn
# t.me/ximistuffs
