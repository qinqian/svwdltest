task hello {
  String name

  command {
    echo 'Hello ${name}!' > test.out
  }

  runtime {
    cpu: 2
    pbs_queue: 'q1'
  }

  output {
    String response = read_string("test.out")
  }
}

workflow test {
  call hello
}

