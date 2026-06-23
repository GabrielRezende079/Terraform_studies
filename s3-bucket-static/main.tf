provider "aws" {
    region = "us-east-1"
  
}
// Cria um bucket S3 genericamente, assim eu defino o nome para cada projeto
variable "bucket_name" {

    // coloco nessa variavel
    type = string
}

// Cria o bucket S3 para site estatico, usando o nome definido na variavel
resource "aws_s3_bucket" "static_site_bucket" {

    // o nome do bucket tem que ser unico, por isso concateno static-site- com o nome definido na variavel
    bucket = "static-site-${var.bucket_name}"

// Habilita o site estatico no bucket, definindo o documento de index e o documento de erro
    website {
        index_document = "index.html"
        error_document = "error.html"
    }

// Tags são para identificar recuros e organização, como se fosse uma descrição
    tags = {
        Name = "Static Site Bucket"
        Environment = "Production"
    }
}

// Configura o bloqueio de acesso público para o bucket, permitindo que ele seja acessível publicamente para servir o site estático
resource "aws_s3_bucket_public_access_block" "static_site_bucket"{
    bucket = aws_s3_bucket.static_site_bucket.id

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false

}

// Configura as regras de propriedade do bucket para garantir que o proprietário do bucket tenha controle total sobre os objetos, mesmo que sejam carregados por outros usuários
resource "aws_s3_ownership_controls" "static_site_bucket" {
    bucket = aws_s3_bucket.static_site_bucket.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}


// Configura a ACL (Access Control List) do bucket para "public-read", permitindo que os objetos no bucket sejam lidos publicamente,
// o que é necessário para servir um site estático
resource "aws_s3_bucket_acl" "static_site_bucket_bucket" {
    depends_on = [
        aws_s3_bucket_public_access_block.static_site_bucket.id,
        aws_s3_ownership_controls.static_site_bucket.id
    ]
    bucket = aws_s3_bucket.static_site_bucket.id
    acl    = "public-read"
}




