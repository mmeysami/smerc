#' Determine sequence of ULS zones.
#' 
#' \code{uls.zones} determines the unique zones obtained by implementing the ULS (Upper Level Set) method of Patil and Taillie (2004).
#' 
#' The zones returned must have a total population less than ubpop * the total population of all regions in the study area.
#' 
#' @inheritParams uls.test
#' @return Returns a list of zones to consider for clustering.  Each element of the list contains a vector with the location ids of the regions in that zone.
#' @author Joshua French
#' @export
#' @references Patil, G. P., and Taillie, C. (2004). Upper level set scan statistic for detecting arbitrarily shaped hotspots. Environmental and Ecological Statistics, 11(2), 183-197.
#' @examples 
#' data(nydf)
#' data(nyw)
#' uls.zones(cases = nydf$cases, pop = nydf$population, w = nyw)
uls.zones = function(cases, pop, w, ubpop = 0.5)
{
  if(length(cases) != length(pop)) stop('length(cases) != length(pop)')
  if(length(cases) != nrow(w)) stop('length(cases) != nrow(w)')
  if(length(ubpop) != 1 | !is.numeric(ubpop)) stop("ubpop should be a single number")
  if(ubpop <= 0 | ubpop > 1) stop("ubpop not in (0, 1]")
  
  # order rates from largest to smallest
  or = order(cases/pop, decreasing = TRUE);
  # reorder rows and columns by order of r
  w = w[or, ]
  w = w[, or]
  
  #unique zones, first zone always the starting point
  uz = vector("list", nrow(w))
  uz[[1]] = 1
  
  # current zones
  cz = 1
  for(i in 2:nrow(w))
  {
    #are regions adjacent
    which_adjacent = which(w[1:(i-1), i] == 1)
    # if there are no neighbors for the new vertex
    if(length(which_adjacent) == 0)
    {
      # add new zone to list
      uz[[i]] = i
      # update current zones
      cz = c(cz, i)
   }else
    {
      # which zones intersect
      wzi = which(unlist(lapply(uz[cz], function(x) length(intersect(x, which_adjacent)) > 0), use.names = FALSE))
      # add new zone to list
      uz[[i]] = c(unlist(uz[cz[wzi]], use.names = FALSE), i)
      # update current zones
      cz = c(cz[-wzi], i)
    }
  }
  # convert back to original location ids
  uz = lapply(uz, function(x) or[x])
  # return only the zones that meet constraint for population upper bound
  popin = lapply(uz, function(x) sum(pop[x]))
  return(uz[which(popin <= sum(pop) * ubpop)])
}