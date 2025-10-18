if test ! -e dagger.json
  echo "Dagger.json not found..."
  return 1
end
if test ! -e ./dagger/sdk
  echo "Generated SDK (./dagger/sdk) not found..."
  return 1
end
venv
python -m pip install -e ./dagger/sdk
