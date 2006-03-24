"rb" <- 
function(lmRob.object, M = 1000, seed = 99, fixed = T)
{

	x <- model.matrix(lmRob.object)
	y <- model.extract(model.frame(lmRob.object), response)

#
# this method is currently only
# implemented for MM-estimates
#
	if( lmRob.object$est != "final" ) {
		stop("This method is only implemented for MM-regression estimates")
		return(invisible())
	}

	m <- lmRob.object$coeff
	s <- lmRob.object$T.coeff
	scale <- lmRob.object$scale

	tmp <- lmRob.object$robust.control$weight

# chi.fn = type of weight function for the initial estimate
# psi.fn = type of weight function for the final   estimate

	if( tmp[1] == "Bisquare" )
		chi.fn <- 1
	else if( tmp[1] == "Optimal" )
		chi.fn <- 2

	if( tmp[2] == "Bisquare" )
		psi.fn <- 1
	else if( tmp[2] == "Optimal" )
		psi.fn <- 2

# tuning.psi = tuning constant for the final estimate
# tuning.chi = tuning constant for the initial estimate
# beta       = right hand side of the initial estimate equation
#
# the numbers below are for 95% efficient estimates
# we should get them directly from the lmRob.object
#
# I think the parameters for the initial estimate
# are always the same (they don't depend on the efficiency), namely
# tuning.chi = 1.54764 - beta = 0.5 for "Bisquare", and
# tuning.chi = 1.060158 - beta = 0.2661 for "Optimal"
#
	if( tmp[2] == "Bisquare" ) {
		tuning.psi <- 4.685061
		tuning.chi <- 1.54764
		beta <- 0.5
	}
	else if( tmp[2] == "Optimal" ) {
		tuning.psi <- 1.060158
		tuning.chi <- 0.4047
		beta <- 0.2661
	}

	n <- (d <- dim(x))[1]
	p <- d[2]
	if(fixed)
		a <- .C("s_rb_fixed",
			as.double(x),
			as.double(y),
			as.integer(n),
			as.integer(p),
			as.integer(M),
			ours = as.double(rep(0, M * p)),
			m = as.double(m),
			s = as.double(m),
			scale = as.double(scale),
			as.integer(seed),
			as.double(tuning.chi),
			as.double(tuning.psi),
			as.integer(chi.fn),
			as.integer(psi.fn),
			as.double(beta))
	else a <- .C("s_rb_rand",
			as.double(x),
			as.double(y),
			as.integer(n),
			as.integer(p),
			as.integer(M),
			ours = as.double(rep(0, M * p)),
			m = as.double(m),
			s = as.double(s),
			scale = as.double(scale),
			as.integer(seed),
			as.double(tuning.chi),
			as.double(tuning.psi),
			as.integer(chi.fn),
			as.integer(psi.fn),
			as.double(beta))
	a$ours <- matrix(a$ours, nrow = M)
	return(list(se=colStdevs(a$ours), call = match.call()))
}
