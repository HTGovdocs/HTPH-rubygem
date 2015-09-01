module HTPH::Hathinormalize

  @@month_rx = Regexp.new(/(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)/);

  def self.agency (ag)
    ag.upcase!;
    ag.gsub!(/[,\.:;]|\'S?/, '');   # punctuations
    ag.gsub!(/[\(\)\{\}\[\]]/, ''); # Brackets
    ag.gsub!(/FOR SALE BY.*/, '');  # I AM NOT INTERESTED IN WHAT YOU ARE SELLING KTHXBYE.
    ag.gsub!(/PRINTED (AT|BY).*/, '');   # Don't care where you got prunt or who prant you.
    ag.gsub!(/DISTRIBUTED BY.*/, '');                  # Shoot the messenger.
    ag.gsub!(/AVAILABLE (BY|FOR|FROM|THROUGH|TO).*/, ''); # Don't care.
    ag.gsub!(/.*COPIES.*/, ''); # Don't care.
    ag.gsub!(/^PREPARED .*/, ''); # Don't care.
    ag.gsub!(/SUPT OF.*/, '');
    ag.gsub!(/\b(THE) /, ''); # Stop words
    # Abbreviations et cetera.
    ag.gsub!(/DEPARTMENT/, 'DEPT');
    ag.gsub!(/DEPTOF/, 'DEPT OF'); # Strangely common typo(?)
    ag.gsub!(/&/, ' AND ');
    ag.gsub!(/UNITED STATES( OF AMERICA)?/, 'US');
    ag.gsub!(/U\sS\s|U S$/, 'US ');
    ag.gsub!(/GOV(ERNMEN|\')T/, 'GOVT');
    ag.gsub!(/ (SPN|RES)$/, '');
    # US GOVT PRINT OFF, which is so common yet has so many variations.
    ag.sub!(/(US\s?)?GOVT\s?PRINT(ING)?\s?OFF(ICE)?/, 'USGPO');
    ag.sub!(/U\s?S\s?G\s?P\s?O/, 'USGPO');
    ag.sub!(/^GPO$/, 'USGPO');
    ag.sub!(/AUTHOR *$/, '');
    ag.sub!(/\?/, ''); # Be sure.
    ag.gsub!(/ +/, ' '); # whitespace
    ag.sub!(/^ +/,  '');
    ag.sub!(/ +$/,  '');
    return ag;
  end

  def self.enumc (e)
    e.upcase!;
    e.gsub!(/ +/, " ");

    # Deal with copies
    e.gsub!(/\b(C|COPY?)[ .]*\d+/, "");
    e.gsub!(/(\d+(ST|ND|RD|TH)|ANOTHER) COPY/, "");

    e.gsub!(/VOL(UME)?/, "V");
    e.gsub!(/[\(\)\[\]\*]/, "");
    e.gsub!(/SUPP?(L(EMENT)?)?S?/, "SUP");
    e.gsub!(/&/, " AND ");
    e.gsub!(/\.(\S)/, ". \\1");
    e.gsub!(/\*/, "");
    # e.gsub!(/ \-/, "-");
    e.strip!;

    return e;
  end

  def self.title (t)
    t.upcase!;
    t.gsub!(/[^A-Z0-9]+/, ' ');
    t.gsub!(/ +/, ' '); # whitespace
    t.sub!(/^ /,  '');
    t.sub!(/ $/,  '');
    return t;
  end

  def self.oclc (o)
    # an oclc is only \d+ and has no leading zeroes.
    o.gsub!(/\D/, '');
    o.gsub!(/^0+/, '');
    return o;
  end

  def self.sudoc (s)
    s.gsub!(/ +/, ''); # NO whitespace
    s.upcase!;
    s.sub!(/SUDOCS?/,  '');
    s.gsub!(/[\(\)\{\}\[\]]/, ''); # Brackets    
    s.gsub!(/[^A-Z0-9-]+$/, '');    # No non-alphas other than '-' allowed at the end.
    return s;
  end 

  def self.pubdate (p)
    p.strip!                                                 
    p.upcase!                                                

    c = 0;
    while p =~ @@month_rx do                                   
      month = $1;                                               
      p.sub!(/#{month}[^ ]*/, month.downcase);               
      c += 1;
      raise "Stuck in loop" if c > 100;
    end                                                         
    
    p.gsub!(/BETWEEN(.+?)(?:AND|TO)(.+)/, '\1' + '-' + '\2');
    p.gsub!(/\s(TO|NOT AFTER)\s/, '-');                      
    
    p.gsub!(/[^a-z0-9\-]+/, " ");                            
    p.gsub!(/ +/, " ");                                      
    p.sub!(/^ +/, "");                                       
    p.sub!(/ +$/, "");                                       
    p.gsub!(/\s*-\s*/, '-');                                 
    p.upcase!                                                

    return p;
  end

end
