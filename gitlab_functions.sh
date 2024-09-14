# start collapsed section
function section_start () {
  local section_title="${1}"
  local section_description="${2:-$section_title}"

  echo -e "section_start:`date +%s`:${section_title}[collapsed=true]\r\e[0K${section_description}"
}

# end section
function section_end () {
  local section_title="${1}"

  echo -e "section_end:`date +%s`:${section_title}\r\e[0K"
}

# export with template
function export_godot () {
  local platform="${1}"
  local path="${2}"
  if [ "$TEMPLATE" = "template_debug" ]; then
    godot --headless --verbose --export-debug "${platform}" ${path}
  else
    godot --headless --verbose --export-release "${platform}" ${path}
  fi
}