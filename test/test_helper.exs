ExUnit.start()

# Configure git for test repos if not already set globally (needed in fresh CI environments)
{_, rc} = System.shell("git config --global user.email", stderr_to_stdout: true)

if rc != 0 do
  System.shell("git config --global user.email 'test@vsntool.test'")
  System.shell("git config --global user.name 'Test'")
  System.shell("git config --global init.defaultBranch main")
end
