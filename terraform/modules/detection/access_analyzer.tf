resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = "lab-external-access"
  type          = "ACCOUNT"
}
