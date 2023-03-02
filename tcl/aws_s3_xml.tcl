namespace eval qc::aws {
    namespace export s3
    namespace ensemble create
}

namespace eval qc::aws::s3 {
    namespace export xml2ldict
    namespace ensemble create

    proc _xml_select { xmlDoc xpath} {
        #| Returns xml nodes specified by the supplied xpath.
        set doc [dom parse $xmlDoc]
        set root [$doc documentElement]
        if { [$root hasAttribute xmlns] } {
            # Any namespace specified in the xmlns attribute is mapped 
            # to "ns" for use in the xpath query.
            $doc selectNodesNamespaces "ns [$root getAttribute xmlns]"
        }
        return [$root selectNodes $xpath] 
    }

    proc _xml_node2dict { node } {
        #| Converts an XML tdom node into a dict.
        set dict [list]
        set nodes [$node childNodes]
        foreach node $nodes {
            if { [llength [$node childNodes]] > 1 \
                 || ([llength [$node childNodes]] == 1 \
                     && [ne [[$node firstChild] nodeType] TEXT_NODE] ) } {
                lappend dict [$node nodeName] [_xml_node2dict $node]
            }  elseif { [llength [$node childNodes]] == 0 } {
                # empty node
                lappend dict [$node nodeName] {}
            } else {
                lappend dict [$node nodeName] [$node asText]
            }
        }
        return $dict
    }
        
    proc xml2ldict { xmlDoc xpath } {
        #| Returns ldict for xml nodes selected by xpath.
        set result [list]
        foreach node [_xml_select $xmlDoc $xpath] {
            lappend result [_xml_node2dict $node]
        }
       return $result
    }
}

