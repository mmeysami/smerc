#' Determine zones for \code{elliptic.test}
#'
#' @inheritParams elliptic.test
#'
#' @return A list with all distinct zones, the associated
#' shape parameters, and the associated angle parameters.
#' @export
#' @examples
#' data(nydf)
#' coords = with(nydf, cbind(longitude, latitude))
#' out = elliptic.zones(coords = coords, pop = nydf$pop,
#'                      shape = 1.5, nangle = 4)
#'
elliptic.zones = function(coords, pop, ubpop = 0.5,
                      shape = c(1, 1.5, 2, 3, 4, 5),
                      nangle = c(1, 4, 6, 9, 12, 15)) {
  # convert to proper format
  coords = as.matrix(coords)
  N = nrow(coords)

  # compute inter-centroid distances
  d = lapply(seq_along(shape), function(i) {
    all.shape.dists(shape[i], nangle[i], coords)
  })
  if (length(shape) > 1) {
    d = do.call(rbind, d)
  } else {
    d = d[[1]]
  }
  
  # for each region, determine sorted nearest neighbors
  # subject to population constraint
  mynn = nnpop(d, pop, ubpop)
  
  # number of nns for each max ellipse
  nnn = unlist(lapply(mynn, length))
  
  # determine all shapes and angles for all potential clusters
  shape_all = rep(rep(shape, times = N * nangle), 
                  times = nnn)
  
  angle_all = unlist(sapply(seq_along(nangle), function(i) {
    seq(90, 270, len = nangle[i] + 1)[-(nangle[i] + 1)]
  }))
  angle_all = rep(rep(angle_all, each = N), times = nnn)
  
  # determine distinct zones
  pri = randtoolbox::get.primes(N)
  wdup = duplicated(unlist(lapply(mynn, function(x) cumsum(log(pri[x])))))
  
  # determine positions in mynn of all zones
  allpos = cbind(rep(seq_along(mynn), times = nnn),
                 unlist(sapply(nnn, seq_len)))
  
  # remove zones with a test statistic of 0
  # or fewer than minimum number of cases or
  # indistinct
  w0 = which(wdup)
  shape_all = shape_all[-w0]
  angle_all = angle_all[-w0]
  allpos = allpos[-w0,]
  
  # construct all zones
  zones = apply(allpos, 1, function(x) mynn[[x[1]]][seq_len(x[2])])
  
  return(list(zones = zones, shape = shape_all, angle = angle_all))
}
